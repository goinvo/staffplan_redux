# frozen_string_literal: true

module Mutations
  class UpsertWorkWeek < BaseMutation
    description 'Create or update a work week record for a StaffPlan user.'

    # arguments passed to the `resolve` method
    argument :actual_hours, Int, required: false, description: 'The hours the user actually worked on this project during this week.'
    argument :assignment_id, ID, required: true, description: 'The ID of the assignment this work week is being created for.'
    argument :cweek, Int, required: true, description: 'The calendar week number of the work week.'
    argument :estimated_hours, Int, required: false, description: 'The hours the user is expecting to work on this project during this week.'
    argument :year, Int, required: true, description: 'The calendar year of the work week.'

    # return type from the mutation
    type Types::StaffPlan::WorkWeekType

    def resolve(assignment_id:, cweek:, year:, estimated_hours: 0, actual_hours: 0)
      assignment = context[:current_company].assignments.find(assignment_id)
      work_week = assignment.upsert_work_week(cweek:, year:, estimated_hours: estimated_hours.to_i, actual_hours: actual_hours.to_i)

      # edits are allowed to the user's work weeks prior to their deactivation week, inclusive
      raise GraphQL::ExecutionError, work_week.errors[:base].first if work_week.errors.of_kind?(:base, :locked)

      work_week
    end
  end
end
