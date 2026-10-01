# frozen_string_literal: true

require 'test_helper'

class SettingsPageTest < ApplicationSystemTestCase
  test 'shows the company settings page' do
    passwordless_sign_in(create(:membership).user)

    visit settings_company_url

    assert_text 'General settings'
  end

  test 'updates the company name' do
    membership = create(:membership)
    passwordless_sign_in(membership.user)

    visit settings_company_url
    fill_in 'company[name]', with: 'New Company Name'
    click_button 'Save'

    assert_text 'Updates saved!'
    assert_equal 'New Company Name', membership.company.reload.name
  end
end
