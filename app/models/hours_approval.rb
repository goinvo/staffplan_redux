# frozen_string_literal: true

class HoursApproval
  include ActiveModel::Model

  validate :week_open

  def initialize(assignments:, monday:)
    @window = Timeline::Window.new(start: monday)
    @hours = Timeline::WeeklyHours.new(assignments:, window: @window)
    super()
  end

  def save
    return false if invalid?

    WorkWeek.transaction do
      @hours.assignments.each do |assignment|
        work_week = @hours.work_week(assignment, week)
        work_week.update!(actual_hours: work_week.estimated_hours) if work_week.estimated_hours.positive?
      end
    end
  end

  private

  def week = @window.weeks.first

  def week_open
    return if (week.past? || week.current?) && @hours.for(week).actual.zero?

    errors.add(:base, 'Hours can only be recorded for past weeks without actual hours')
  end
end
