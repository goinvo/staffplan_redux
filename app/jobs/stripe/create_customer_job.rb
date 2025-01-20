module Stripe
  class CreateCustomerJob < ApplicationJob
    queue_as :default
    self.queue_adapter = :solid_queue

    def perform(company)
      owner = company.memberships.find_by!(role: 'owner').user

      if company.stripe_id.blank?
        stripe_customer = Stripe::Customer.create(
          {
            name: "#{company.name} | #{owner.name}",
            email: owner.email,
          }
        )

        company.update(stripe_id: stripe_customer.id)
      end

      if company.subscription.stripe_id.blank?
        # create base subscription
        stripe_subscription = Stripe::Subscription.create(
          {
            customer: company.stripe_id,
            items: [{
              price: Rails.application.credentials.stripe_price_id,
              quantity: company.memberships.active.count
            }],
            trial_period_days: 30,
            trial_settings: {
              end_behavior: {
                missing_payment_method: "cancel"
              }
            },
            payment_settings: {
              save_default_payment_method: 'on_subscription',
            }
          })
        company.subscription.update(stripe_id: stripe_subscription.id)
      end
    end
  end

end
