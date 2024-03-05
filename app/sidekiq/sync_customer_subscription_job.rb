class SyncCustomerSubscriptionJob
  include Sidekiq::Job

  def perform(id)
    company = Company.find_by!(id: id)
    return if company.blank?

    subscription_count = company.memberships.active.count

    Stripe::Subscription.update(
      company.subscription.stripe_id,
      { items: [
        {id: company.subscription.item_id,  quantity: subscription_count }
      ]}
    )
  end
end
