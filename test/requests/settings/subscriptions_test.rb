# frozen_string_literal: true

require 'test_helper'

module Settings
  class SubscriptionsTest < ActionDispatch::IntegrationTest
    include ActiveJob::TestHelper

    test 'generates a Stripe billing portal URL and redirects to it' do
      VCR.use_cassette('Settings_Subscriptions/creating_a_new_subscription/generates_a_URL_to_Stripe_and_redirects_the_user_to_Stripe') do
        registration = create(:registration, name: 'Static Name', email: 'static@email.com')
        perform_enqueued_jobs { registration.register! }
        passwordless_sign_in(registration.reload.user)

        get new_settings_subscription_path

        assert_response :see_other
        assert_match %r{\Ahttps://billing\.stripe\.com/p/session/}, response.location
      end
    end
  end
end
