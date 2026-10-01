# frozen_string_literal: true

require 'test_helper'

module Stripe
  class SyncCustomerSubscriptionJobTest < ActiveJob::TestCase
    test 'fails if it cannot find the company' do
      assert_raises(StandardError) { Stripe::SyncCustomerSubscriptionJob.perform_now(Company.new) }
    end

    test 'informs Stripe of the new quantity' do
      # registration runs Stripe::CreateCustomerJob against the recorded Stripe responses
      VCR.use_cassette('SyncCustomerSubscriptionJob/perform/informs_Stripe_of_the_new_quantity') do
        registration = create(:registration, email: 'something@static.com')
        perform_enqueued_jobs { registration.register! }
      end

      assert_equal 1, Company.count

      company = Company.first

      assert_equal 'sub_1PYVhoBLjyMcgacQcGcNMLMI', company.subscription.stripe_id

      assert_equal 1, company.memberships.active.count

      create(:membership, company:)

      assert_equal 2, company.memberships.active.count

      calls = []
      Stripe::Subscription.stub(:update, ->(*args) { calls << args }) do
        Stripe::SyncCustomerSubscriptionJob.perform_now(company)
      end

      assert_equal [[company.subscription.stripe_id, { items: [{ id: company.subscription.item_id, quantity: 2 }] }]], calls
    end
  end
end
