class CreateStripeCustomerJob
  include Sidekiq::Job

  def perform(id)
    company = Company.find_by!(id: id)

    owner = company.memberships.find_by!(role: 'owner').user

    stripe_customer = Stripe::Customer.create(
      {
        name: "#{company.name} | #{owner.name}",
        email: owner.email,
      }
    )

    company.update(stripe_id: stripe_customer.id)
  end
end
