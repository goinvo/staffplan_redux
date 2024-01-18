require 'rails_helper'

RSpec.describe "Subscription Management", type: :system, vcr: true, headless: true do
  before do
    Sidekiq::Testing.inline!
  end

  describe "with no subscription" do
    it "shows a page with some content and a link to go create a subscription" do
      registration = create(:registration)
      registration.register!
      user = registration.user
      passwordless_sign_in(user)

      visit settings_billing_information_url
      expect(page).to have_text("StaffPlan costs $3 per month, per user. There are no hidden fees or extra charges.")
      expect(page).to have_css("a[href='#{new_settings_subscription_path}']")
    end
  end

  describe "with an active subscription" do
    it "shows information about the subscription" do
      registration = create(:registration)
      registration.register!
      user = registration.user
      passwordless_sign_in(user)

      expect(user.companies.length).to eq(1)
      company = user.companies.first

      # attach a test payment method
      method = Stripe::PaymentMethod.attach(
        "pm_card_visa",
        {customer: company.stripe_id}
      )

      # actually create the subscription
      Stripe::Subscription.create(
        {
          customer: company.stripe_id,
          items: [{price: Rails.application.credentials.stripe_price_id}],
          default_payment_method: method.id,
        }
      )

      visit settings_billing_information_url

      expect(page).to have_text("Your StaffPlan subscription comes with no cap on the number of clients or projects that you can track.")
    end
  end

  describe "cancelling a subscription" do
    it "cancels the subscription" do
      registration = create(:registration)
      registration.register!
      user = registration.user
      passwordless_sign_in(user)

      expect(user.companies.length).to eq(1)
      company = user.companies.first

      # attach a test payment method
      method = Stripe::PaymentMethod.attach(
        "pm_card_visa",
        {customer: company.stripe_id}
      )

      # actually create the subscription
      Stripe::Subscription.create(
        {
          customer: company.stripe_id,
          items: [{price: Rails.application.credentials.stripe_price_id}],
          default_payment_method: method.id,
        }
      )

      visit settings_billing_information_url

      click_button "Cancel my subscription"

      expect(page).to have_text("Your subscription has been cancelled.")
      expect(Stripe::Subscription.list(customer: company.stripe_id).count).to eq(0)
    end
  end
end