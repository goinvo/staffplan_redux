class SyncCustomerSubscriptionCountJob
  include Sidekiq::Job

  def perform(id)
    company = Company.find_by!(id: id)
    return if company.blank?

    # TODO: when there's a free trial, we'll check the trial's expiration here
    subscription = company.subscription
    return if subscription.blank?

    subscription_count = company.memberships.active.count
    item_id = subscription.items.first.id

    Stripe::Subscription.update(
      subscription.id,
      { items: [
        {id: item_id,  quantity: subscription_count }
      ]}
    )

    BillingMailer.subscription_updated(company, subscription_count).deliver_now
  end
end
