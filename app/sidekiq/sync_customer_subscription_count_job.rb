class SyncCustomerSubscriptionCountJob
  include Sidekiq::Job

  def perform(id)
    company = Company.find_by!(id: id)


    subscription_count = company.memberships.active.count

    stripe_customer = Stripe::Customer.create(
      {
        name: "#{company.name} | #{owner.name}",
        email: owner.email,
      }
    )

    company.update(stripe_id: stripe_customer.id)
  end
end
