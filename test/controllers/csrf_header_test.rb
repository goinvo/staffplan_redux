# frozen_string_literal: true

require 'test_helper'

class ExampleController < ApplicationController
  def index
    head :ok
  end
end

class ExampleControllerTest < ActionDispatch::IntegrationTest
  tests ExampleController

  describe 'any controller action in the app' do
    it 'sets an X-CSRF-Token header value' do
      token = 'a csrf token'
      @controller.stub :form_authenticity_token, token do
        # Add route directly in test
        @routes = ActionDispatch::Routing::RouteSet.new
        @routes.draw do
          get '/test', to: 'example#index'
        end

        get :index

        assert_equal token, response.headers['X-CSRF-Token']
      end
    end
  end
end
