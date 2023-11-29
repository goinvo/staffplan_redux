# frozen_string_literal: true

class StaffPlanColumnHeaderComponent < ViewComponent::Base
  def initialize(beginning_of_week:)
    @beginning_of_week = beginning_of_week
  end

  def date_plus_count(count)
    (@beginning_of_week + count.weeks).to_i
  end
end
