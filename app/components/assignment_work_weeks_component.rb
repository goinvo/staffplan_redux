# frozen_string_literal: true

class AssignmentWorkWeeksComponent < ViewComponent::Base
  def initialize(assignment:, beginning_of_week: nil)
    @assignment = assignment
    @beginning_of_week = beginning_of_week
    @work_weeks = assignment.work_weeks
  end

  def work_week_for(beginning_of_week)
    @work_weeks.detect { |work_week| work_week.beginning_of_week == beginning_of_week }
  end
end
