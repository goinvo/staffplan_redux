# frozen_string_literal: true

require 'test_helper'
require 'minitest/mock'

module Webhooks
  class StripeTest < ActionDispatch::IntegrationTest
    include ActiveJob::TestHelper

    SIGNING_SECRET = 'whsec_test_secret'

    setup do
      @company = create(:company, stripe_id: 'cus_TestStaffPlan01')
    end

    test 'customer.subscription.created saves the trialing subscription' do
      post_event stripe_event('customer.subscription.created')

      assert_response :ok
      subscription = @company.subscription.reload

      assert_equal 'trialing', subscription.status
      assert_equal 'sub_TestStaffPlan01', subscription.stripe_id
      assert_equal 'si_TestItem0001', subscription.item_id
      assert_equal 'price_TestMonthly01', subscription.stripe_price_id
      assert_equal 300, subscription.plan_amount
      assert_equal 3, subscription.quantity
      assert_equal Time.zone.at(1_759_276_800), subscription.current_period_start
      assert_equal Time.zone.at(1_761_868_800), subscription.current_period_end
      assert_equal Time.zone.at(1_761_868_800), subscription.trial_end
      assert_nil subscription.canceled_at
      assert_no_enqueued_emails
    end

    test 'customer.subscription.created reads the billing period from pre-basil payloads' do
      event = stripe_event('customer.subscription.created')
      subscription = event['data']['object']
      item = subscription['items']['data'].first
      subscription['current_period_start'] = item.delete('current_period_start')
      subscription['current_period_end'] = item.delete('current_period_end')

      post_event event

      assert_response :ok
      assert_equal Time.zone.at(1_759_276_800), @company.subscription.reload.current_period_start
      assert_equal Time.zone.at(1_761_868_800), @company.subscription.current_period_end
    end

    test 'customer.subscription.updated saves the active subscription and emails owners about the new quantity' do
      @company.subscription.update!(quantity: 3)

      assert_enqueued_email_with BillingMailer, :subscription_updated, args: [@company, 4] do
        post_event stripe_event('customer.subscription.updated')
      end

      assert_response :ok
      subscription = @company.subscription.reload

      assert_equal 'active', subscription.status
      assert_equal 4, subscription.quantity
      assert_equal Time.zone.at(1_761_868_800), subscription.current_period_start
      assert_equal Time.zone.at(1_764_547_200), subscription.current_period_end
      assert_nil subscription.canceled_at
    end

    test 'customer.subscription.updated records a cancellation at period end' do
      @company.subscription.update!(quantity: 3)

      post_event stripe_event('customer.subscription.updated.cancel_at_period_end')

      assert_response :ok
      subscription = @company.subscription.reload

      assert_equal 'active', subscription.status
      assert_equal Time.zone.at(1_762_300_800), subscription.canceled_at
      assert_predicate subscription, :canceled?
      assert_no_enqueued_emails
    end

    test 'customer.subscription.deleted marks the subscription canceled' do
      post_event stripe_event('customer.subscription.deleted')

      assert_response :ok
      subscription = @company.subscription.reload

      assert_equal 'canceled', subscription.status
      assert_equal Time.zone.at(1_761_868_800), subscription.canceled_at
      assert_equal Time.zone.at(1_761_868_800), subscription.current_period_end
      assert_no_enqueued_emails
    end

    test 'customer.updated saves the customer and card details' do
      payment_method = Stripe::PaymentMethod.construct_from(
        id: 'pm_TestCard00001',
        object: 'payment_method',
        type: 'card',
        card: { brand: 'visa', last4: '4242', exp_month: 12, exp_year: 2030 },
      )

      Stripe::PaymentMethod.stub(:retrieve, ->(id) { payment_method if id == 'pm_TestCard00001' }) do
        post_event stripe_event('customer.updated')
      end

      assert_response :ok
      subscription = @company.subscription.reload

      assert_equal 'billing@acme.co', subscription.customer_email
      assert_equal 'Acme Co | Owner Person', subscription.customer_name
      assert_equal 'pm_TestCard00001', subscription.default_payment_method
      assert_equal 'card', subscription.payment_method_type
      assert_equal(
        {
          'credit_card_brand' => 'visa',
          'credit_card_last_four' => '4242',
          'credit_card_exp_month' => 12,
          'credit_card_exp_year' => 2030,
        },
        subscription.payment_metadata,
      )
    end

    test 'customer.updated without a default payment method saves only the customer details' do
      event = stripe_event('customer.updated')
      event['data']['object']['invoice_settings']['default_payment_method'] = nil

      post_event event

      assert_response :ok
      subscription = @company.subscription.reload

      assert_equal 'billing@acme.co', subscription.customer_email
      assert_nil subscription.default_payment_method
    end

    test 'events for an unknown customer are acknowledged without changes' do
      @company.update!(stripe_id: 'cus_SomeoneElse')

      %w[
        customer.subscription.created
        customer.subscription.updated
        customer.subscription.deleted
        customer.updated
      ].each do |name|
        post_event stripe_event(name)

        assert_response :ok
      end

      assert_nil @company.subscription.reload.stripe_id
      assert_nil @company.subscription.customer_email
    end

    test 'unhandled event types are acknowledged' do
      event = stripe_event('customer.subscription.created')
      event['type'] = 'invoice.paid'

      post_event event

      assert_response :ok
      assert_nil @company.subscription.reload.stripe_id
    end

    test 'a bad signature is rejected' do
      post_event stripe_event('customer.subscription.created'), secret: 'whsec_wrong'

      assert_response :bad_request
      assert_nil @company.subscription.reload.stripe_id
    end

    test 'a missing signature is rejected' do
      with_signing_secret do
        post webhooks_stripe_path,
             params: stripe_event('customer.subscription.created').to_json,
             headers: { 'Content-Type' => 'application/json' }
      end

      assert_response :bad_request
    end

    private

    def post_event(event, secret: SIGNING_SECRET)
      payload = event.to_json
      timestamp = Time.current
      signature = Stripe::Webhook::Signature.compute_signature(timestamp, payload, secret)
      header = Stripe::Webhook::Signature.generate_header(timestamp, signature)

      with_signing_secret do
        post webhooks_stripe_path,
             params: payload,
             headers: { 'Content-Type' => 'application/json', 'Stripe-Signature' => header }
      end
    end

    def stripe_event(name)
      JSON.parse(file_fixture("stripe_events/#{name}.json").read)
    end

    def with_signing_secret(&)
      Rails.application.credentials.stub(:stripe_signing_secret, SIGNING_SECRET, &)
    end
  end
end
