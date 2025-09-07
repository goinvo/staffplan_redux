# frozen_string_literal: true

module StaffPlan
  class WeekHeaderCellComponent < ViewComponent::Base
    def initialize(work_week:)
      @work_week = work_week
    end

    attr_reader :work_week

    def current_month
      start_date.month
    end

    def date_range_text
      "#{start_date.strftime('%-d.%b')} to #{end_date.strftime('%-d.%b')}"
    end

    def day_number
      work_week.day
    end

    def end_date
      @end_date ||= start_date + 6.days
    end

    def is_first_week_of_month?
      # Check if this week starts in a different month than the previous week
      current_month != previous_month
    end

    def month_abbreviation
      is_first_week_of_month? ? start_date.strftime('%b') : ''
    end

    def previous_month
      previous_week_date.month
    end

    def previous_week_date
      @previous_week_date ||= start_date - 1.week
    end

    def start_date
      @start_date ||= Date.commercial(work_week.year, work_week.cweek, 1)
    end

    def text_classes
      work_week.is_current_week? ? 'font-bold' : ''
    end

    def th_classes
      classes = ['relative py-2 px-1 font-normal text-contrastBlue']
      classes << 'bg-selectedColumnBg' if work_week.is_current_week?
      classes.join(' ')
    end
  end
end
