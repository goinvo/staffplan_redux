# frozen_string_literal: true

require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test 'POST #create does not raise an error if called with missing params' do
    post registrations_path, params: {}

    assert_equal 'Sorry, please try that again.', flash[:alert]
  end
end
