class Settings::SubscriptionsController < ApplicationController

  def new
    price = Stripe::Price.retrieve(Rails.application.credentials.stripe_price_id)

    begin
      session = Stripe::Checkout::Session.create({
        mode: 'subscription',
        customer: current_company.stripe_id,
        billing_address_collection: 'required',
        line_items: [{
          quantity: current_company.users.count,
          price: price.id
        }],
        success_url: Rails.application.credentials.stripe_redirect_host + '/settings/billing_information?session_id={CHECKOUT_SESSION_ID}',
        cancel_url: Rails.application.credentials.stripe_redirect_host + '/settings/billing_information',
       })
    rescue StandardError => e
      render json: { 'error': { message: e.error.message } }, status: 400 and return
    end

    redirect_to session.url, status: 303, allow_other_host: true
  end

  def destroy
    subscriptions = Stripe::Subscription.list(customer: current_company.stripe_id)
    subscriptions.map do |subscription|
      Stripe::Subscription.delete(subscription.id)
    end

    flash[:success] = "Your subscription has been cancelled."
    redirect_to settings_billing_information_path
  end
end
