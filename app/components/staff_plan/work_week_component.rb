# frozen_string_literal: true

module StaffPlan
  class WorkWeekComponent < ViewComponent::Base
    def initialize(work_week:)
      @work_week = work_week
    end
    attr_reader :work_week

    def actual_hours_display
      work_week.actual_hours.positive? ? work_week.actual_hours : ''
    end

    def estimated_hours_display
      work_week.estimated_hours.positive? ? work_week.estimated_hours : ''
    end

    def show_actual_input?
      !work_week.is_future_work_week?
    end
  end
end
