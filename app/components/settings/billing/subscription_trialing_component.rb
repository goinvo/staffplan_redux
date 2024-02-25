module Settings
  module Billing
    class SubscriptionTrialingComponent < ViewComponent::Base
      def initialize(company:)
        @company = company
      end

      def subscription
        @company.subscription
      end
    end
  end
end