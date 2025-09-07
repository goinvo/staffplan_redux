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

    def is_current_week?
      today = Time.zone.today
      today.cwyear == work_week.year && today.cweek == work_week.cweek
    end

    def td_classes
      classes = ['relative px-1 py-1 font-normal']
      classes << 'bg-selectedColumnBg' if is_current_week?
      classes.join(' ')
    end

    def div_classes
      classes = ['flex flex-col sm:justify-normal justify-center h-full sm:space-y-3 pt-5 sm:pt-0']
      classes << 'font-bold' if is_current_week?
      classes.join(' ')
    end
  end
end
