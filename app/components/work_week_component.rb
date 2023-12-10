# frozen_string_literal: true

class WorkWeekComponent < ViewComponent::Base
  def initialize(work_week:, assignment:, work_week_beginning_of_week:, beginning_of_week:)
    @assignment = assignment
    @work_week = work_week || @assignment.work_weeks.new(beginning_of_week: work_week_beginning_of_week)
    @work_week_beginning_of_week = work_week_beginning_of_week
    @beginning_of_week = beginning_of_week
  end

  def actual_hours
    @work_week&.actual_hours || 0
  end

  def proposed_hours
    @work_week&.proposed_hours || 0
  end

  def work_week_form(&block)
    form_for @work_week do |form|
      yield(form)
    end
  end

  def render_actual_hours?
    @work_week_beginning_of_week <= @beginning_of_week
  end
end
