require 'rails_helper'

RSpec.describe "Subscription Management", type: :system, vcr: true, headless: true do
  before do
    Sidekiq::Testing.inline!
  end

  # TODO: these tests are great, but the individual components should have their own tests
  describe "when trialing" do
    it "shows a page with some content and a link to go set up payment for a subscription" do
      registration = create(:registration)
      registration.register!
      user = registration.reload.user
      passwordless_sign_in(user)

      visit settings_billing_information_url
      expect(page).to have_text("Your free trial has no limitations")
      expect(page).to have_text("Manage StaffPlan Subscription")
    end
  end

  describe "with an active subscription" do
    it "shows information about the subscription when in a trial period" do
      registration = create(:registration)
      registration.register!
      user = registration.reload.user
      passwordless_sign_in(user)

      expect(user.companies.length).to eq(1)
      company = user.companies.first

      company.subscription.update(
        status: 'trialing',
        trial_end: 30.days.from_now,
        stripe_id: Faker::Alphanumeric.alpha(number: 10),
        stripe_price_id: Faker::Alphanumeric.alpha(number: 10),
        customer_name: company.name,
        customer_email: user.email,
        plan_amount: 300,
        quantity: 1,
        item_id: Faker::Alphanumeric.alpha(number: 10),
        default_payment_method: Faker::Alphanumeric.alpha(number: 10),
        current_period_start: 60.minutes.ago,
        current_period_end: 30.days.from_now,
        payment_method_type: "card",
        payment_metadata: {
          credit_card_brand: 'visa',
          credit_card_last_four: '4242',
          credit_card_exp_month: '12',
          credit_card_exp_year: '29'
        }
      )

      visit settings_billing_information_url

      expect(page).to have_text("StaffPlan Subscription (free trial period!)")
    end

    it "shows information about the subscription when an active, paying subscription" do
      registration = create(:registration)
      registration.register!
      user = registration.reload.user
      passwordless_sign_in(user)

      expect(user.companies.length).to eq(1)
      company = user.companies.first

      company.subscription.update(
        status: 'active',
        trial_end: 30.days.from_now,
        stripe_id: Faker::Alphanumeric.alpha(number: 10),
        stripe_price_id: Faker::Alphanumeric.alpha(number: 10),
        customer_name: company.name,
        customer_email: user.email,
        plan_amount: 300,
        quantity: 1,
        item_id: Faker::Alphanumeric.alpha(number: 10),
        default_payment_method: Faker::Alphanumeric.alpha(number: 10),
        current_period_start: 60.minutes.ago,
        current_period_end: 30.days.from_now,
        payment_method_type: "card",
        payment_metadata: {
          credit_card_brand: 'visa',
          credit_card_last_four: '4242',
          credit_card_exp_month: '12',
          credit_card_exp_year: '29'
        }
      )

      visit settings_billing_information_url

      expect(page).to have_text("Your StaffPlan subscription comes with no cap on the number of clients or projects that you can track")
    end
  end
end