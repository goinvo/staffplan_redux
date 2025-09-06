# frozen_string_literal: true

module StaffPlan
  class ClientsComponent < ViewComponent::Base
    def initialize(user:)
      @user = user
    end
    attr_reader :user
  end
end
