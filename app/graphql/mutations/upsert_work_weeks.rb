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

      WorkWeek.transaction do
        work_weeks.each do |ww|
          work_week = assignment.work_weeks.find_or_initialize_by(cweek: ww.cweek, year: ww.year)

          if work_week.is_future_work_week? && (
            ww.estimated_hours.blank? || ww.estimated_hours.zero?
          )
            # the front end will send nil or 0 values for work weeks that should be deleted
            work_week.destroy
          else
            values = ww.to_h.slice(:estimated_hours, :actual_hours).tap do |v|
              v[:estimated_hours] = v[:estimated_hours].to_i
              v[:actual_hours] = v[:actual_hours].to_i
            end

            work_week.update(values)
          end
        end
      end

      assignment
    end
  end
end
