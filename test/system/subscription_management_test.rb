# frozen_string_literal: true

require 'test_helper'

class SubscriptionManagementTest < ApplicationSystemTestCase
  def registered_user
    registration = create(:registration)
    registration.register!
    registration.reload.user
  end

  def subscription_attributes(company:, user:, status:)
    {
      status:,
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
      payment_method_type: Subscription::CARD,
      payment_metadata: {
        credit_card_brand: 'visa',
        credit_card_last_four: '4242',
        credit_card_exp_month: '12',
        credit_card_exp_year: '29',
      },
    }
  end

  test 'shows a trialing company how to set up payment' do
    passwordless_sign_in(registered_user)

    visit settings_billing_information_url

    assert_text 'Your free trial has no limitations'
    assert_text 'Manage StaffPlan Subscription'
  end

  test 'shows subscription details during a trial with a payment method' do
    user = registered_user
    passwordless_sign_in(user)

    assert_equal 1, user.companies.length

    company = user.companies.first
    company.subscription.update!(subscription_attributes(company:, user:, status: Subscription::TRIALING))

    visit settings_billing_information_url

    assert_text 'StaffPlan Subscription (free trial period!)'
  end

  test 'shows subscription details for an active, paying subscription' do
    user = registered_user
    passwordless_sign_in(user)

    assert_equal 1, user.companies.length

    company = user.companies.first
    company.subscription.update!(subscription_attributes(company:, user:, status: Subscription::ACTIVE))

    visit settings_billing_information_url

    assert_text 'Your StaffPlan subscription comes with no cap on the number of clients or projects that you can track'
  end
end
