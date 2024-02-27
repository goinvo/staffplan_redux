module Stripe
  class SubscriptionUpdated
    def initialize(subscription)
      @subscription = subscription
    end

    def call
      company = Company.find_by(stripe_id: @subscription.customer)
      if company.blank?
        Rollbar.report_message("Customer not found for Stripe ID: #{@customer.id}", 'warning')
        return
      end

      previous_quantity = company.subscription.quantity

      canceled_at = @subscription.canceled_at.present? ? Time.at(@subscription.canceled_at) : nil
      company.subscription.assign_attributes(
        status: @subscription.status,
        trial_end: Time.at(@subscription.trial_end),
        stripe_id: @subscription.id,
        stripe_price_id: @subscription.items.data.first.price.id,
        plan_amount: @subscription.items.data.first.price.unit_amount,
        quantity: @subscription.quantity,
        item_id: @subscription.items.data.first.id,
        current_period_start: Time.at(@subscription.current_period_start),
        current_period_end: Time.at(@subscription.current_period_end),
        canceled_at: canceled_at
      )

      company.subscription.save!

      if previous_quantity != company.subscription.quantity
        BillingMailer.subscription_updated(company, company.subscription.quantity).deliver_later
      end
    end
  end
end