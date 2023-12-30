# frozen_string_literal: true

module StaffPlan
  class WorkWeekComponent < ViewComponent::Base
    def initialize(work_week: nil, assignment:, work_week_beginning_of_week:, beginning_of_week:)
      @assignment = assignment
      @work_week_beginning_of_week = work_week_beginning_of_week
      @beginning_of_week = beginning_of_week
      @work_week = work_week || new_work_week
    end

    def actual_hours
      @work_week.actual_hours
    end

    def estimated_hours
      @work_week.estimated_hours
    end

    def work_week_form(&block)
      form_for @work_week, url: form_path, data: { work_week_target: "form" } do |form|
        yield(form)
      end
    end

    def render_actual_hours?
      # only allow input for work weeks that are the current week or in the past
      Time.zone.now.at_beginning_of_week.to_i >= @work_week_beginning_of_week
    end

    def turbo_frame_id
      helpers.work_week_turbo_frame_id(@work_week)
    end

    def form_path
      if @work_week.persisted?
        staff_plans_work_week_path(@work_week)
      else
        staff_plans_work_weeks_path
      end
    end

    private



    def new_work_week
      date = Time.at(@work_week_beginning_of_week.to_i).to_date

      @assignment.work_weeks.new(
        assignment: @assignment,
        beginning_of_week: @work_week_beginning_of_week,
        cweek: date.cweek,
        year: date.year
      )
    end
  end

end