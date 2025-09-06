# frozen_string_literal: true

module StaffPlan
  class AssignmentComponent < ViewComponent::Base
    def initialize(user:, assignment:, client:, index:)
      @user = user
      @assignment = assignment
      @client = client
      @index = index
    end
    attr_reader :user, :assignment, :client, :index

    def actual_hours_sum
      assignment
        .work_weeks
        .sum(:actual_hours)
    end

    def client_name
      return '' if index.positive?

      client.name
    end

    def project # rubocop:disable Rails/Delegate
      assignment.project
    end

    def planned_hours_sum # rubocop:disable Layout/OrderedMethods
      assignment
        .work_weeks
        .where('(year < ?) OR (year = ? AND cweek <= ?)', today.cwyear, today.cwyear, today.cweek)
        .sum(:estimated_hours)
    end

    def today
      Time.zone.today.beginning_of_week
    end

    def work_weeks
      # hard code to 26 weeks
      start_date = today - 1.week
      end_date = Time.zone.today.beginning_of_week + 24.weeks

      weeks = assignment
        .work_weeks
        .where('(cweek >= ? AND year = ?) OR (cweek <= ? AND year = ?)',
               start_date.cweek,
               start_date.cwyear,
               end_date.cweek,
               end_date.cwyear,)

      # Create a hash for quick lookup by cweek/year
      weeks_by_date = weeks.index_by { |w| [w.cweek, w.year] }

      # Build the fixed-size array of 26 elements
      result = []
      current_date = start_date

      26.times do
        key = [current_date.cweek, current_date.cwyear]
        result << (weeks_by_date[key] || WorkWeek.new(
          assignment: assignment,
          cweek: current_date.cweek,
          year: current_date.cwyear,
        ))
        current_date += 1.week
      end

      result
    end
  end
end
