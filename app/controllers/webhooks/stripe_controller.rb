class Webhooks::StripeController < ApplicationController

  skip_before_action :verify_authenticity_token
  skip_before_action :check_subscription_status

  def create
    endpoint_secret = Rails.application.credentials.stripe_signing_secret
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      Rollbar.error(e)
      status 400 and return
    end

    case event.type
    when "customer.subscription.updated"
      Stripe::SubscriptionUpdated.new(event.data.object).call
    when "customer.subscription.deleted"
      handle_customer_subscription_deleted(event)
    when "customer.subscription.created"
      handle_customer_subscription_created(event)
    when "customer.updated"
      Stripe::CustomerUpdated.new(event.data.object).call
    else
      puts "Unhandled event type: #{event.type}"
    end

    head 200
  end

  private

  # TODO: move these to a service object

  def handle_customer_subscription_deleted(event)
    # when a trial runs out? cancel the subscription.
    subscription = event.data.object
    company = Company.find_by(stripe_id: subscription.customer)
    if company.blank?
      # Rollbar.report_message("Customer not found for Stripe ID: #{@customer.id}", 'warning')
      return
    end

    company.subscription.update(
      status: subscription.status,
      trial_end: Time.at(subscription.trial_end),
      stripe_id: subscription.id,
      stripe_price_id: subscription.items.data.first.price.id,
      plan_amount: subscription.items.data.first.price.unit_amount,
      quantity: subscription.quantity,
      item_id: subscription.items.data.first.id,
      current_period_start: Time.at(subscription.current_period_start),
      current_period_end: Time.at(subscription.current_period_end)
    )
  end

  def handle_customer_subscription_created(event)
    # CreateStripeCustomerJob creates a base subscription with a 30 day trial
    # this is the webhook that receives the subscription created event and will persist
    # the relevant subscription data so we have it
    subscription = event.data.object
    company = Company.find_by(stripe_id: subscription.customer)
    if company.blank?
      # Rollbar.report_message("Customer not found for Stripe ID: #{@customer.id}", 'warning')
      return
    end

    company.subscription.update(
      status: subscription.status,
      trial_end: Time.at(subscription.trial_end),
      stripe_id: subscription.id,
      stripe_price_id: subscription.items.data.first.price.id,
      plan_amount: subscription.items.data.first.price.unit_amount,
      quantity: subscription.quantity,
      item_id: subscription.items.data.first.id,
      current_period_start: Time.at(subscription.current_period_start),
      current_period_end: Time.at(subscription.current_period_end)
    )
  end
end
