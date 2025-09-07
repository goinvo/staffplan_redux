# frozen_string_literal: true

module StaffPlan
  class AssignmentComponent < ViewComponent::Base
    def initialize(user:, assignment:, client:, index:, target_date:)
      @user = user
      @assignment = assignment
      @client = client
      @index = index
      @target_date = target_date
    end
    attr_reader :user, :assignment, :client, :index, :target_date

    def client_name
      return '' if index.positive?

      client.name
    end

    def project # rubocop:disable Rails/Delegate
      assignment.project
    end

    def work_weeks
      # hard code to 26 weeks
      start_date = target_date - 1.week
      end_date = target_date + 24.weeks

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
          assignment_id: assignment.id,
          cweek: current_date.cweek,
          year: current_date.cwyear,
        ))
        current_date += 1.week
      end

      result
    end
  end
end
