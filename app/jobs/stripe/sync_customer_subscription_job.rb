module Stripe
  class SyncCustomerSubscriptionJob < ApplicationJob
    queue_as :default
    self.queue_adapter = :solid_queue

    def perform(company)
      subscription_count = company.memberships.active.count

      Stripe::Subscription.update(
        company.subscription.stripe_id,
        { items: [
          {id: company.subscription.item_id,  quantity: subscription_count }
        ]}
      )
    end
  end
end
