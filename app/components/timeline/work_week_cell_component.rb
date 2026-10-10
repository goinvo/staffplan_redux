# frozen_string_literal: true

module Timeline
  class WorkWeekCellComponent < ViewComponent::Base
    attr_reader :assignment, :work_week, :week, :disabled, :padded

    def initialize(assignment:, work_week:, week:, disabled: false, padded: false)
      @assignment = assignment
      @work_week = work_week
      @week = week
      @disabled = disabled
      @padded = padded
    end

    def actual? = week.past? || week.current?

    def actual_value
      work_week.actual_hours if work_week.actual_hours.positive?
    end

    def estimated_value
      work_week.estimated_hours if work_week.persisted? || work_week.estimated_hours.positive?
    end

    def input_options(kind, value)
      {
        type: 'text',
        name: "work_week[#{kind == :plan ? 'estimated_hours' : 'actual_hours'}]",
        value:,
        id: "#{kind == :plan ? 'estHours' : 'actHours'}-#{assignment.id}-#{week.cweek}-#{week.year}",
        disabled:,
        autocomplete: 'off',
        inputmode: 'numeric',
        maxlength: 3,
        data: { kind: },
        aria: { label: "#{assignment.project.name} #{kind == :plan ? 'plan' : 'actual'} hours, week of #{week.monday.strftime('%b %-d, %Y')}" },
        class: [
          disabled ? 'timeline-grid-bg' : 'bg-white shadow-top-input-shadow',
          'text-center sm:text-base text-2xl rounded-sm sm:w-[34px] w-[68px] sm:h-[25px] h-[50px] focus:border-tiffany focus:ring-1 focus:ring-tiffany border-none mb-0 px-0 py-0',
        ],
      }
    end
  end
end
