# frozen_string_literal: true

module People
  class AssignmentRowComponent < ViewComponent::Base
    attr_reader :assignment, :window, :hours, :sort, :index, :first_client, :show_hidden, :inactive

    def initialize(assignment:, window:, hours:, sort:, index:, first_client:, show_hidden: false, inactive: false) # rubocop:disable Metrics/ParameterLists
      @assignment = assignment
      @window = window
      @hours = hours
      @sort = sort
      @index = index
      @first_client = first_client
      @show_hidden = show_hidden
      @inactive = inactive
    end

    def actual_total
      @actual_total ||= assignment.work_weeks.sum(&:actual_hours)
    end

    def client_label?
      !sort.by_client? || first_client
    end

    def future_plan
      assignment.work_weeks
        .select { (it.is_future_work_week? || it.is_current_week?) && it.actual_hours.zero? }
        .sum(&:estimated_hours)
    end

    def plan_tooltip
      "Plan = Future Plan (#{helpers.number_with_delimiter(future_plan)}) + Actual (#{helpers.number_with_delimiter(actual_total)})"
    end

    def proposed?
      assignment.status == Assignment::PROPOSED
    end

    def row_class
      [
        'flex sm:justify-normal justify-between bg-white-300 hover:bg-hoverGrey pl-5',
        ('bg-diagonal-stripes' if proposed?),
        ('border-t border-gray-300' if index.positive? && (!sort.by_client? || first_client)),
      ]
    end

    def show_button?
      show_hidden && !assignment.focused
    end

    def toggled_status
      proposed? ? Assignment::ACTIVE : Assignment::PROPOSED
    end
  end
end
