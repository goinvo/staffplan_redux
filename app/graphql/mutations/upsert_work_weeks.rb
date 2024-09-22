module Mutations
  class UpsertWorkWeeks < BaseMutation
    description "Create or update a work week record for a StaffPlan user."

    # arguments passed to the `resolve` method
    argument :assignment_id, ID, required: true, description: "The ID of the assignment this work week is being created for."
    argument :work_weeks, [Types::StaffPlan::WorkWeeksInputObject], required: true, description: "Attributes for creating or updating a work week record for a StaffPlan user."

    # return type from the mutation
    type Types::StaffPlan::AssignmentType

    def resolve(assignment_id:, work_weeks:)
      current_company = context[:current_company]

      # try and find the assignment
      assignment = current_company.assignments.find(assignment_id)

      unless assignment.user.memberships.active.exists?(company: current_company)
        # if the assignment isn't for an active user, raise an error
        raise GraphQL::ExecutionError, "User is not an active member of the company"
      end

      work_weeks.each do |ww|
        work_week = assignment.work_weeks.find_or_initialize_by(cweek: ww.cweek, year: ww.year)
        work_week.update!(ww.to_h.slice(:estimated_hours, :actual_hours))
      end

      assignment
    end
  end
end
