# frozen_string_literal: true

class WorkWeekComponent < ViewComponent::Base
  def initialize(work_week: new_work_week, assignment:, work_week_beginning_of_week:, beginning_of_week:)
    @assignment = assignment
    @work_week_beginning_of_week = work_week_beginning_of_week
    @beginning_of_week = beginning_of_week
    @work_week = work_week
  end

  def actual_hours
    @work_week.actual_hours
  end

  def estimated_hours
    @work_week.estimated_hours
  end

  def work_week_form(&block)
    form_for @work_week, data: { work_week_target: "form" } do |form|
      yield(form)
    end
  end

  def render_actual_hours?
    @work_week_beginning_of_week <= @beginning_of_week
  end

  private

  def new_work_week
    date = Time.at(@work_week_beginning_of_week.to_i).to_date

    @assignment.work_weeks.new(
      beginning_of_week: @work_week_beginning_of_week,
      cweek: date.cweek,
      year: date.year
    )
  end
end
