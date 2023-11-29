# frozen_string_literal: true

class AssignmentRowComponent < ViewComponent::Base
  def initialize(assignment:, work_weeks:)
    @assignment = assignment
    @project = @assignment.project
    @work_weeks = work_weeks
  end

end
