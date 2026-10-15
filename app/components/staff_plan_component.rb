# frozen_string_literal: true

class StaffPlanComponent < ViewComponent::Base
  def initialize(user:, target_date: Time.zone.today)
    @user = user
    @target_date = target_date
  end
  attr_reader :user, :target_date
end
