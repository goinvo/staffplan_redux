# frozen_string_literal: true

require 'test_helper'

class RailsUiRolloutTest < ActionDispatch::IntegrationTest
  REACT_UI_URL = 'https://ui.example.test'

  class RailsUiPageController < ApplicationController
    before_action :require_user!
    before_action :require_rails_ui!

    def show
      head :ok
    end
  end

  setup do
    @user = create(:user)
  end

  test 'an allowlisted user lands on the Rails UI after signing in' do
    rails_ui(emails: "other@example.com, #{@user.email.upcase}") do
      passwordless_sign_in @user

      get root_path

      assert_redirected_to "/people/#{@user.id}"
    end
  end

  test 'every user lands on the Rails UI when it is enabled for all' do
    rails_ui(enabled: 'true') do
      passwordless_sign_in @user

      get root_path

      assert_redirected_to "/people/#{@user.id}"
    end
  end

  test 'other users still land on the React app after signing in' do
    rails_ui(emails: 'other@example.com') do
      passwordless_sign_in @user

      get root_path

      assert_redirected_to "#{REACT_UI_URL}/people/#{@user.id}"
    end
  end

  test 'a signed in user visiting sign in is sent to their UI' do
    rails_ui(emails: @user.email) do
      passwordless_sign_in @user

      get auth_sign_in_path

      assert_redirected_to "/people/#{@user.id}"
    end
  end

  test 'nav links point at the Rails UI for an allowlisted user' do
    rails_ui(emails: @user.email) do
      passwordless_sign_in @user

      get settings_profile_path

      assert_dom "a[href='/people/#{@user.id}']", text: 'My StaffPlan'
      assert_dom "a[href='/people']", text: 'People'
      assert_dom "a[href='/projects']", text: 'Projects'
    end
  end

  test 'nav links point at the React app for other users' do
    rails_ui do
      passwordless_sign_in @user

      get settings_profile_path

      assert_dom "a[href='#{REACT_UI_URL}/people/#{@user.id}']", text: 'My StaffPlan'
      assert_dom "a[href='#{REACT_UI_URL}/people']", text: 'People'
      assert_dom "a[href='#{REACT_UI_URL}/projects']", text: 'Projects'
    end
  end

  test 'Rails UI pages redirect to the same page in the React app when the switch is off' do
    rails_ui do
      with_rails_ui_page_route do
        passwordless_sign_in @user
        get '/people?sort=name'
      end
    end

    assert_redirected_to "#{REACT_UI_URL}/people?sort=name"
  end

  test 'Rails UI pages render when the switch is on' do
    rails_ui(emails: @user.email) do
      with_rails_ui_page_route do
        passwordless_sign_in @user
        get '/people'
      end
    end

    assert_response :ok
  end

  private

  def rails_ui(enabled: '', emails: '', &)
    with_config(react_ui_url: REACT_UI_URL, rails_ui_enabled: enabled, rails_ui_emails: emails, &)
  end

  def with_rails_ui_page_route
    with_routing do |set|
      set.draw do
        passwordless_for :users, at: '/', as: :auth, controller: 'sessions'
        root 'dashboard#show'
        get '/people', to: 'rails_ui_rollout_test/rails_ui_page#show'
      end
      yield
    end
  end
end
