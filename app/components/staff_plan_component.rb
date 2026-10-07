# frozen_string_literal: true

class StaffPlanComponent < ViewComponent::Base
  def initialize(user:, target_date: Time.zone.today)
    @user = user
    @target_date = target_date
  end
  attr_reader :user, :target_date

  def react_staffplan_url
    RailsUi.react_url("/people/#{helpers.current_user.id}")
  end
end
