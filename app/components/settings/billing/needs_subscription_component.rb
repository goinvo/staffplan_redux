module Settings
  module Billing
    class NeedsSubscriptionComponent < ViewComponent::Base
      def initialize(company:)
        @company = company
      end
    end
  end
end