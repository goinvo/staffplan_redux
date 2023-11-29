# frozen_string_literal: true

class AssignmentWorkWeeksComponent < ViewComponent::Base
  def initialize(assignment:, work_weeks:)
    @assignment = assignment
    @work_weeks = work_weeks
  end

end
