# frozen_string_literal: true

module StaffPlan
  class HeaderChartComponent < ViewComponent::Base
    def initialize(user:)
      @user = user
      @target_date = nil
    end
    attr_reader :user, :target_date

    def before_render
      @target_date = if params[:ts]
        (Time.zone.at(params[:ts].to_i) + 2.hours).to_date
      else
        Time.zone.today
      end
    end

    def work_weeks_per_week
      return @work_weeks_per_week if defined?(@work_weeks_per_week)

      # hard code to 26 weeks
      start_date = target_date - 1.week
      end_date = target_date + 24.weeks

      # Get all work weeks for the user in the date range
      weeks = user
        .work_weeks
        .includes(:assignment)
        .joins(:assignment)
        .where(assignment: { status: 'active' })
        .where('(cweek >= ? AND year = ?) OR (cweek <= ? AND year = ?)',
               start_date.cweek,
               start_date.cwyear,
               end_date.cweek,
               end_date.cwyear,)

      # Group work weeks by cweek/year
      weeks_grouped = weeks.group_by { |w| [w.cweek, w.year] }

      # Build the fixed-size array of 26 arrays
      result = []
      current_date = start_date

      26.times do
        key = [current_date.cweek, current_date.cwyear]
        # Return array of work weeks for this week, or a single unsaved WorkWeek if none exist
        result << (weeks_grouped[key] || [WorkWeek.new(
          cweek: current_date.cweek,
          year: current_date.cwyear,
          estimated_hours: 0,
          actual_hours: 0,
        )])
        current_date += 1.week
      end

      @work_weeks_per_week = result
    end
  end
end
