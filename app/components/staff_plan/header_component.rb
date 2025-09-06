# frozen_string_literal: true

module StaffPlan
  class HeaderComponent < ViewComponent::Base
    def initialize(user:)
      @user = user
    end
    attr_reader :user
  end
end
