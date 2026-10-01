# frozen_string_literal: true

module Stripe
  class SaveSubscription
    def initialize(subscription)
      @subscription = subscription
    end

    def call
      company = Company.find_by(stripe_id: @subscription.customer)
      if company.blank?
        # Rollbar.report_message("Customer not found for Stripe ID: #{@subscription.customer}", 'warning')
        return
      end

      item = @subscription.items.data.first

      # API versions before 2025-03-31.basil send the billing period on the subscription
      # instead of on its items. Webhook payloads follow the endpoint's API version.
      current_period_start = item[:current_period_start] || @subscription[:current_period_start]
      current_period_end = item[:current_period_end] || @subscription[:current_period_end]

      company.subscription.update!(
        status: @subscription.status,
        trial_end: timestamp(@subscription.trial_end),
        stripe_id: @subscription.id,
        stripe_price_id: item.price.id,
        plan_amount: item.price.unit_amount,
        quantity: item.quantity,
        item_id: item.id,
        current_period_start: timestamp(current_period_start),
        current_period_end: timestamp(current_period_end),
        canceled_at: timestamp(@subscription.canceled_at),
      )

      company
    end

    private

    def timestamp(value)
      value.present? ? Time.zone.at(value) : nil
    end
  end
end
