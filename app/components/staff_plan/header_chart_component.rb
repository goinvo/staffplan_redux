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

    def max_hours_value
      return @max_hours_value if defined?(@max_hours_value)

      max_actual_hours = 0
      max_estimated_hours = 0
      max_proposed_actual_hours = 0
      max_proposed_estimated_hours = 0

      work_weeks_per_week.each do |work_weeks_array|
        # Calculate totals for this week
        total_actual = 0
        total_estimated = 0
        proposed_actual = 0
        proposed_estimated = 0

        work_weeks_array.each do |work_week|
          # Add actual hours
          actual = work_week.actual_hours || 0
          total_actual += actual

          # Add estimated hours
          estimated = work_week.estimated_hours || 0
          total_estimated += estimated

          # Add proposed hours if assignment is proposed
          if work_week.assignment&.status == 'proposed'
            proposed_actual += actual
            proposed_estimated += estimated
          end
        end

        # Track maximums
        max_actual_hours = total_actual if total_actual > max_actual_hours
        max_estimated_hours = total_estimated if total_estimated > max_estimated_hours
        max_proposed_actual_hours = proposed_actual if proposed_actual > max_proposed_actual_hours
        max_proposed_estimated_hours = proposed_estimated if proposed_estimated > max_proposed_estimated_hours
      end

      # Return the maximum of all types of hours
      @max_hours_value = [
        max_actual_hours,
        max_estimated_hours,
        max_proposed_actual_hours,
        max_proposed_estimated_hours,
        50, # Minimum max value to prevent division issues
      ].max
    end

    def work_weeks_per_week
      return @work_weeks_per_week if defined?(@work_weeks_per_week)

      # Ensure target_date is set (for console testing)
      @target_date ||= Time.zone.today

      # hard code to 26 weeks
      start_date = target_date - 1.week
      end_date = target_date + 24.weeks

      # Get all work weeks for the user in the date range
      weeks = user
        .work_weeks
        .includes(:assignment)
        .joins(:assignment)
        .where(assignment: { status: %w[active proposed] })
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
