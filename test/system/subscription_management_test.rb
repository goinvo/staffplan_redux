# frozen_string_literal: true

require 'test_helper'

class SubscriptionManagementTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  # Registers a company end to end: Stripe::CreateCustomerJob runs against the
  # recorded Stripe responses and stores the customer and subscription ids
  def registered_user(cassette)
    VCR.use_cassette("Subscription_Management/#{cassette}") do
      registration = create(:registration)
      perform_enqueued_jobs { registration.register! }
      registration.reload.user
    end
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
    user = registered_user('when_trialing/shows_a_page_with_some_content_and_a_link_to_go_set_up_payment_for_a_subscription')
    company = user.current_company

    assert_equal 'cus_VOhFvV0QrjWHKQ', company.stripe_id
    assert_equal 'sub_1UNtqcBLjyMcgacQhISpdwvp', company.subscription.stripe_id
    assert_predicate company.subscription, :trialing?

    passwordless_sign_in(user)

    visit settings_billing_information_url

    assert_text 'Your free trial has no limitations'
    assert_text 'Manage StaffPlan Subscription'
  end

  test 'shows subscription details during a trial with a payment method' do
    user = registered_user('with_an_active_subscription/shows_information_about_the_subscription_when_in_a_trial_period')
    passwordless_sign_in(user)

    assert_equal 1, user.companies.length

    company = user.companies.first
    company.subscription.update!(subscription_attributes(company:, user:, status: Subscription::TRIALING))

    visit settings_billing_information_url

    assert_text 'StaffPlan Subscription (free trial period!)'
  end

  test 'shows subscription details for an active, paying subscription' do
    user = registered_user('with_an_active_subscription/shows_information_about_the_subscription_when_an_active_paying_subscription')
    passwordless_sign_in(user)

    assert_equal 1, user.companies.length

    company = user.companies.first
    company.subscription.update!(subscription_attributes(company:, user:, status: Subscription::ACTIVE))

    visit settings_billing_information_url

    assert_text 'Your StaffPlan subscription comes with no cap on the number of clients or projects that you can track'
  end
end
