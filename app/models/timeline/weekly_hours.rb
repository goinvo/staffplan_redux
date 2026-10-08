# frozen_string_literal: true

module Timeline
  class WeeklyHours
    Hours = Data.define(:actual, :estimated, :proposed) do
      def actual? = actual.positive?

      def total = actual? ? actual : estimated
    end

    attr_reader :assignments, :window

    def initialize(assignments:, window:)
      @assignments = assignments.to_a
      @window = window
    end

    def for(week)
      by_week.fetch(week.index)
    end

    def max
      @max ||= by_week.values.map { [it.actual, it.estimated].max }.max
    end

    def work_week(assignment, week)
      work_weeks[[assignment.id, week.year, week.cweek]] ||
        WorkWeek.new(assignment:, year: week.year, cweek: week.cweek, estimated_hours: weekly_estimate(assignment, week))
    end

    private

    def by_week
      @by_week ||= window.weeks.to_h { [it.index, sum(it)] }
    end

    def sum(week)
      actual = estimated = proposed = 0

      assignments.each do |assignment|
        work_week = work_week(assignment, week)

        actual += work_week.actual_hours
        estimated += work_week.estimated_hours
        proposed += work_week.estimated_hours if assignment.status == Assignment::PROPOSED
      end

      Hours.new(actual:, estimated:, proposed:)
    end

    def weekly_estimate(assignment, week)
      starts_on = assignment.starts_on
      ends_on = assignment.ends_on
      return 0 if starts_on.blank? || starts_on > week.monday
      return 0 if ends_on.present? && ends_on <= week.monday

      assignment.estimated_weekly_hours.to_i
    end

    def work_weeks
      @work_weeks ||= window.weeks
        .group_by(&:year)
        .map { |year, weeks| WorkWeek.where(year:, cweek: weeks.map(&:cweek)) }
        .inject(:or)
        .where(assignment_id: assignments.map(&:id))
        .index_by { [it.assignment_id, it.year, it.cweek] }
    end
  end
end
