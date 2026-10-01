# frozen_string_literal: true

module Stripe
  class SubscriptionUpdated
    def initialize(subscription)
      @subscription = subscription
    end

    def call
      company = Company.find_by(stripe_id: @subscription.customer)
      return if company.blank?

      previous_quantity = company.subscription.quantity

      SaveSubscription.new(@subscription).call
      company.subscription.reload

      if previous_quantity != company.subscription.quantity
        BillingMailer.subscription_updated(company, company.subscription.quantity).deliver_later
      end
    end
  end
end
