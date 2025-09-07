# frozen_string_literal: true

module StaffPlan
  class ClientsComponent < ViewComponent::Base
    def initialize(user:, target_date:)
      @user = user
      @target_date = target_date
    end
    attr_reader :user, :target_date
  end
end
