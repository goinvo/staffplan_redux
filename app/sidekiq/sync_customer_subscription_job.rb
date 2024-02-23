class SyncCustomerSubscriptionJob
  include Sidekiq::Job

  def perform(id)
    company = Company.find_by!(id: id)
    return if company.blank?

    company.create_subscription if company.subscription.blank?

    # TODO: when there's a free trial, we'll check the trial's expiration here
    stripe_subscription = company.stripe_subscription
    return if stripe_subscription.blank?

    subscription_count = company.memberships.active.count
    item_id = stripe_subscription.items.first.id

    Stripe::Subscription.update(
      stripe_subscription.id,
      { items: [
        {id: item_id,  quantity: subscription_count }
      ]}
    )

    BillingMailer.subscription_updated(company, subscription_count).deliver_now
  end
end
