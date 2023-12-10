# frozen_string_literal: true

class AssignmentRowComponent < ViewComponent::Base
  def initialize(assignment:, work_weeks:, beginning_of_week:)
    @assignment = assignment
    @project = @assignment.project
    @work_weeks = work_weeks
    @beginning_of_week = beginning_of_week
  end

end
