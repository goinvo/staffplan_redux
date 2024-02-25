module Settings
  module Billing
    class SubscriptionTrialingComponent < ViewComponent::Base
      def initialize(company:)
        @company = company
      end
    end
  end
end