module Mutations
  class UpsertWorkWeek < BaseMutation
    description "Create or update a work week record for a StaffPlan user."

    # arguments passed to the `resolve` method
    argument :assignment_id, ID, required: true, description: "The ID of the assignment this work week is being created for."
    argument :cweek, Int, required: true, description: "The calendar week number of the work week."
    argument :year, Int, required: true, description: "The calendar year of the work week."
    argument :estimated_hours, Int, required: false, description: "The hours the user is expecting to work on this project during this week."
    argument :actual_hours, Int, required: false, description: "The hours the user actually worked on this project during this week."

    # return type from the mutation
    type Types::StaffPlan::WorkWeekType

    def resolve(assignment_id:, cweek:, year:, estimated_hours: 0, actual_hours: 0)
      current_company = context[:current_company]

      # try and find the assignment
      assignment = current_company.assignments.find(assignment_id)

      if assignment.user && !Membership.active.exists?(user: assignment.user, company: current_company)
        # if the assignment isn't for an active user, raise an error
        raise GraphQL::ExecutionError, "User is not an active member of the company"
      end

      # otherwise, try and find a work week for the current company by assignment, cweek, and year
      work_week = current_company.work_weeks.find_by(assignment_id:, cweek:, year:)

      if work_week.blank?
        # create it. unable to do this through current_company.work_weeks becaues it goes through more than one other association
        work_week = WorkWeek.create!(assignment_id:, cweek:, year:)
      end

      if work_week.is_future_work_week? && (
        estimated_hours.blank? || estimated_hours.zero?
      )
        # the front end will send nil or 0 values for work weeks that should be deleted
        work_week.destroy
      else
        work_week.update(estimated_hours: estimated_hours.to_i, actual_hours: actual_hours.to_i)
      end

      work_week
    end
  end
end
