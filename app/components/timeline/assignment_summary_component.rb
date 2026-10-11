# frozen_string_literal: true

module Timeline
  class AssignmentSummaryComponent < ViewComponent::Base
    attr_reader :assignment

    def initialize(assignment:)
      @assignment = assignment
    end

    def actual_total
      @actual_total ||= assignment.work_weeks.sum(&:actual_hours)
    end

    def future_plan
      assignment.work_weeks
        .select { (it.is_future_work_week? || it.is_current_week?) && it.actual_hours.zero? }
        .sum(&:estimated_hours)
    end

    def plan_tooltip
      "Plan = Future Plan (#{helpers.number_with_delimiter(future_plan)}) + Actual (#{helpers.number_with_delimiter(actual_total)})"
    end
  end
end
