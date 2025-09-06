# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test 'POST #create does not raise an error if called with missing params' do
    post sign_in_path, params: {}

    assert_equal 'Sorry, please try that again.', flash[:alert]
  end
end
