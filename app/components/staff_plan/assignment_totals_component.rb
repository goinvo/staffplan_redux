# frozen_string_literal: true

module StaffPlan
  class AssignmentTotalsComponent < ViewComponent::Base
    def initialize(assignment:)
      @assignment = assignment
      @target_date = Time.zone.today.beginning_of_week
    end
    attr_reader :assignment, :target_date

    def actual_hours_sum
      assignment
        .work_weeks
        .sum(:actual_hours)
    end

    def current_week_in_range?
      today = Time.zone.today
      start_date = target_date - 1.week
      end_date = target_date + 24.weeks

      # Check if current week falls within the displayed range
      today.between?(start_date, end_date)
    end

    def planned_hours_sum
      assignment
        .work_weeks
        .sum(:estimated_hours)
    end

    def sum_classes
      classes = ['text-sm text-right min-w-20']
      classes.unshift('font-bold') if current_week_in_range?
      classes.join(' ')
    end
  end
end
