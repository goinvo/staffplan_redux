# frozen_string_literal: true

module People
  class MobileFooterComponent < ViewComponent::Base
    attr_reader :hours, :approve_path

    def initialize(hours:, approve_path: nil)
      @hours = hours
      @approve_path = approve_path
    end

    def approvable?
      approve_path && (week.past? || week.current?) && planned.positive? && hours.for(week).actual.zero?
    end

    def chart_weeks
      hours.window.weeks.drop(1)
    end

    def planned
      hours.for(week).estimated
    end

    def week
      hours.window.weeks.second
    end
  end
end
