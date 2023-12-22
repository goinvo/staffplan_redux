# frozen_string_literal: true

class StaffPlanComponent < ViewComponent::Base
  def initialize(query:, viewing_user:, beginning_of_week:)
    @query = query
    @viewing_user = viewing_user
    @beginning_of_week = beginning_of_week
  end
end
