class Settings::SubscriptionsController < ApplicationController
  before_action :require_user!
  before_action :require_company_owner_or_admin!
  def new
    session_type = params[:t] || "payment_method_update"

    begin
      case session_type
      when "payment_method_update"
        session = Stripe::BillingPortal::Session.create({
          customer: current_company.stripe_id,
          return_url: Rails.application.credentials.stripe_redirect_host + '/settings/billing_information',
          flow_data: {
            type: "payment_method_update"
          }
        })
      when "subscription_update"
        session = Stripe::BillingPortal::Session.create({
          customer: current_company.stripe_id,
          return_url: Rails.application.credentials.stripe_redirect_host + '/settings/billing_information',
          flow_data: {
            type: "subscription_update",
            subscription_update: {
              subscription: current_company.subscription.stripe_id
            }
          }
        })
      else
        flash[:error] = "Sorry, please try again."
        redirect_to root_url and return
      end

    rescue StandardError => e
      render json: { 'error': { message: e.message } }, status: 400 and return
    end

    redirect_to session.url, status: 303, allow_other_host: true
  end
end
