class Settings::SubscriptionsController < ApplicationController
  before_action :require_user!
  before_action :require_company_owner_or_admin!
  def new
    begin
      session = Stripe::BillingPortal::Session.create({
        customer: current_company.stripe_id,
        return_url: Rails.application.credentials.stripe_redirect_host + '/settings/billing_information',
        flow_data: {
          type: "payment_method_update"
        }
      })
    rescue StandardError => e
      render json: { 'error': { message: e.message } }, status: 400 and return
    end

    redirect_to session.url, status: 303, allow_other_host: true
  end

  def destroy
    Stripe::Subscription.cancel(current_company.subscription.id)

    flash[:success] = "Your subscription has been cancelled."
    redirect_to settings_billing_information_path
  end
end
