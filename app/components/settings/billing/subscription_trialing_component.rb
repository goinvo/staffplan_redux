# frozen_string_literal: true

module Settings
  module Billing
    class SubscriptionTrialingComponent < ViewComponent::Base
      def initialize(company:)
        @company = company
      end

      delegate :subscription, to: :@company
    end
  end
end
