# frozen_string_literal: true

module StaffPlan
  class AssignmentComponent < ViewComponent::Base
    def initialize(assignment:, work_weeks:, beginning_of_week:)
      @assignment = assignment
      @project = @assignment.project
      @work_weeks = work_weeks
      @beginning_of_week = beginning_of_week
    end

  end

end
