# frozen_string_literal: true

class StaffPlanComponent < ViewComponent::Base
  def initialize(user)
    @user = user
  end
  attr_reader :user
end
