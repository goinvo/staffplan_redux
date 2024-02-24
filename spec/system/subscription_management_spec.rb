require 'rails_helper'

RSpec.describe "Subscription Management", type: :system, vcr: true, headless: true do
  before do
    Sidekiq::Testing.inline!
  end

  describe "with no subscription" do
    it "shows a page with some content and a link to go create a subscription" do
      registration = create(:registration)
      registration.register!
      user = registration.reload.user
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
        credit_card_brand: 'visa',
        credit_card_last_four: '4242',
        credit_card_exp_month: '12',
        credit_card_exp_year: '29'
      )

      visit settings_billing_information_url

      expect(page).to have_text("Your StaffPlan subscription comes with no cap on the number of clients or projects that you can track.")
    end
  end

  describe "cancelling a subscription" do
    it "cancels the subscription" do
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
        credit_card_brand: 'visa',
        credit_card_last_four: '4242',
        credit_card_exp_month: '12',
        credit_card_exp_year: '29'
      )

      visit settings_billing_information_url

      click_button "Cancel my subscription"

      expect(page).to have_text("Your subscription has been cancelled.")
      expect(Stripe::Subscription.list(customer: company.stripe_id).count).to eq(0)
    end
  end
end