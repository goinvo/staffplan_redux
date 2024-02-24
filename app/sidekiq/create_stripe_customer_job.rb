class CreateStripeCustomerJob
  include Sidekiq::Job

  def perform(id)
    company = Company.find_by!(id: id)

    owner = company.memberships.find_by!(role: 'owner').user

    if company.stripe_id.blank?
      stripe_customer = Stripe::Customer.create(
        {
          name: "#{company.name} | #{owner.name}",
          email: owner.email,
        }
      )

      company.update(stripe_id: stripe_customer.id)
    else
      stripe_customer = Stripe::Customer.retrieve(company.stripe_id)
    end

    if company.subscription.blank?
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
    else
      stripe_subscription = Stripe::Subscription.retrieve(company.subscription.stripe_id)
    end

    # TODO: none of this belongs here, it should be being received via webhooks from Stripe
    subscription = company.subscription || company.build_subscription

    subscription.update(
      status: stripe_subscription.status,
      trial_end: Time.at(stripe_subscription.trial_end),
      stripe_id: stripe_subscription.id,
      stripe_price_id: stripe_subscription.items.data.first.price.id,
      customer_name: stripe_customer.name,
      customer_email: stripe_customer.email,
      plan_amount: stripe_subscription.items.data.first.price.unit_amount,
      quantity: stripe_subscription.quantity,
      item_id: stripe_subscription.items.data.first.id,
      default_payment_method: stripe_customer.invoice_settings.default_payment_method,
      current_period_start: Time.at(stripe_subscription.current_period_start),
      current_period_end: Time.at(stripe_subscription.current_period_end),
    )

    if stripe_customer.invoice_settings.default_payment_method.present?
      payment_method = Stripe::PaymentMethod.retrieve(stripe_customer.invoice_settings.default_payment_method)
      subscription.update(
        credit_card_brand: payment_method.card.brand,
        credit_card_last_four: payment_method.card.last4,
        credit_card_exp_month: payment_method.card.exp_month,
        credit_card_exp_year: payment_method.card.exp_year
      )
    end
  end
end
