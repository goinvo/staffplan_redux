# frozen_string_literal: true

require 'test_helper'

class RailsUiTest < ActiveSupport::TestCase
  setup do
    @user = build(:user, email: 'Person@Example.com')
  end

  test 'is off when neither switch is set' do
    with_config(rails_ui_enabled: '', rails_ui_emails: '') do
      assert_not RailsUi.enabled_for?(@user)
    end
  end

  test 'is on for everyone when RAILS_UI_ENABLED is true' do
    with_config(rails_ui_enabled: 'true') do
      assert RailsUi.enabled_for?(@user)
    end
  end

  test 'is off when RAILS_UI_ENABLED is anything other than true' do
    with_config(rails_ui_enabled: 'false') do
      assert_not RailsUi.enabled_for?(@user)
    end
  end

  test 'is on for an allowlisted email' do
    with_config(rails_ui_emails: 'person@example.com') do
      assert RailsUi.enabled_for?(@user)
    end
  end

  test 'matches allowlisted emails ignoring case and whitespace' do
    with_config(rails_ui_emails: ' someone@else.com , PERSON@example.COM ,') do
      assert RailsUi.enabled_for?(@user)
    end
  end

  test 'requires an exact email match' do
    with_config(rails_ui_emails: 'son@example.com,person@example.co') do
      assert_not RailsUi.enabled_for?(@user)
    end
  end

  test 'is off without a user' do
    with_config(rails_ui_enabled: 'true') do
      assert_not RailsUi.enabled_for?(nil)
    end
  end

  test 'url points at the React app when the switch is off' do
    with_config(react_ui_url: 'https://ui.example.test', rails_ui_emails: '') do
      assert_equal 'https://ui.example.test/people', RailsUi.url(@user, '/people')
    end
  end

  test 'url points at the Rails UI when the switch is on' do
    with_config(react_ui_url: 'https://ui.example.test', rails_ui_emails: @user.email) do
      assert_equal '/people', RailsUi.url(@user, '/people')
    end
  end
end
