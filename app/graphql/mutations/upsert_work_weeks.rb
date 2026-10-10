# frozen_string_literal: true

module Mutations
  class UpsertWorkWeeks < BaseMutation
    description 'Create or update a work week record for a StaffPlan user.'

    # arguments passed to the `resolve` method
    argument :assignment_id, ID, required: true, description: 'The ID of the assignment this work week is being created for.'
    argument :work_weeks, [Types::StaffPlan::WorkWeeksInputObject], required: true, description: 'Attributes for creating or updating a work week record for a StaffPlan user.'

    # return type from the mutation
    type Types::StaffPlan::AssignmentType

    def resolve(assignment_id:, work_weeks:)
      current_company = context[:current_company]

      # try and find the assignment
      assignment = current_company.assignments.find(assignment_id)

      skip_count = 0

      WorkWeek.transaction do
        work_weeks.each do |ww|
          work_week = assignment.upsert_work_week(cweek: ww.cweek, year: ww.year, estimated_hours: ww.estimated_hours.to_i, actual_hours: ww.actual_hours.to_i)
          skip_count += 1 if work_week.errors.of_kind?(:base, :locked)
        end
      end

      if skip_count.positive?
        context.add_error(
          GraphQL::ExecutionError.new(
            "Unable to update #{skip_count} future work week(s) for an inactive user",
          ),
        )
      end

      assignment
    end
  end
end
