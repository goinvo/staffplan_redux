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

    # create base subscription
    stripe_subscription = Stripe::Subscription.create({
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
    })

    company.create_subscription(
      stripe_id: stripe_subscription.id,
      stripe_price_id: stripe_subscription.items.data.first.price.id,
      customer_name: stripe_customer.name,
      customer_email: stripe_customer.email,
      plan_amount: stripe_subscription.items.data.first.price.unit_amount,
    )
  end
end
