# frozen_string_literal: true

require 'test_helper'

class ExampleController < ApplicationController
  def index
    head :ok
  end
end

class ExampleControllerTest < ActionController::TestCase
  tests ExampleController

  setup do
    # Add route for the test controller
    Rails.application.routes.draw do
      get '/test' => 'example#index'
    end
  end

  teardown do
    # Reload original routes after test
    Rails.application.reload_routes!
  end

  test 'sets an X-CSRF-Token header value' do
    token = 'a csrf token'
    @controller.stub :form_authenticity_token, token do
      get :index

      assert_equal token, response.headers['X-CSRF-Token']
    end
  end
end
