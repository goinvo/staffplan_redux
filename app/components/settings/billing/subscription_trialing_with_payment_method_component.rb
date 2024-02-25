module Settings
  module Billing
    class SubscriptionTrialingWithPaymentMethodComponent < ViewComponent::Base
      def initialize(company:)
        @company = company
      end
    end
  end
end