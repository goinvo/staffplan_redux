# frozen_string_literal: true

module StaffPlan
  class WorkWeekComponent < ViewComponent::Base
    def initialize(work_week:, errors: [])
      @work_week = work_week
      @errors = errors
    end
    attr_reader :work_week, :errors

    def actual_hours_display
      work_week.actual_hours.positive? ? work_week.actual_hours : ''
    end

    def component_id
      work_week.dom_id
    end

    def div_classes
      classes = ['flex flex-col sm:justify-normal justify-center h-full sm:space-y-3 pt-5 sm:pt-0']
      classes << 'font-bold' if work_week.is_current_week?
      classes.join(' ')
    end

    def estimated_hours_display
      work_week.estimated_hours.positive? ? work_week.estimated_hours : ''
    end

    def form_method
      work_week.persisted? ? :patch : :post
    end

    def form_url
      if work_week.persisted?
        Rails.application.routes.url_helpers.staffplan_work_week_path(work_week.user, work_week)
      elsif work_week.assignment_id.present?
        Rails.application.routes.url_helpers.staffplan_work_weeks_path(work_week.user)
      else
        '#' # Fallback for unpersisted work_weeks without assignment
      end
    end

    def show_actual_input?
      !work_week.is_future_work_week?
    end

    def td_classes
      classes = ['relative px-1 py-1 font-normal']
      classes << 'bg-selectedColumnBg' if work_week.is_current_week?
      classes.join(' ')
    end
  end
end
