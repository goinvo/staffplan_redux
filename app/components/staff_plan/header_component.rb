# frozen_string_literal: true

module StaffPlan
  class HeaderComponent < ViewComponent::Base
    def initialize(beginning_of_week:)
      @beginning_of_week = beginning_of_week
    end

    def date_plus_count(count)
      (@beginning_of_week + count.weeks).to_i
    end
  end
end