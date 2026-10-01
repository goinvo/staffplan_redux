# frozen_string_literal: true

require 'test_helper'

class UserManagementTest < ApplicationSystemTestCase
  test 'shows the user management page to admins' do
    membership = create(:membership, role: Membership::ADMIN)
    passwordless_sign_in(membership.user)

    visit settings_users_url

    assert_text membership.user.name
    assert_link 'New User'
  end

  test 'shows the user management page to owners' do
    membership = create(:membership, role: Membership::OWNER)
    passwordless_sign_in(membership.user)

    visit settings_users_url

    assert_text membership.user.name
    assert_link 'New User'
  end

  test 'does not show the user management page to members' do
    membership = create(:membership, role: Membership::MEMBER)
    passwordless_sign_in(membership.user)

    visit settings_users_url

    assert_current_path "/people/#{membership.user_id}"
  end

  test 'adds a new user' do
    membership = create(:membership, role: Membership::ADMIN)
    passwordless_sign_in(membership.user)

    visit settings_users_url
    click_link 'New User'
    fill_in 'Full name', with: Faker::Name.name
    fill_in 'Email', with: Faker::Internet.email

    assert_difference -> { User.count }, 1 do
      click_button 'Create'

      assert_text 'User added successfully'
    end

    assert_current_path settings_users_path
  end

  test 're-renders the form when there are errors' do
    membership = create(:membership, role: Membership::ADMIN)
    passwordless_sign_in(membership.user)

    visit settings_users_url
    click_link 'New User'

    assert_no_difference -> { User.count } do
      click_button 'Create'

      assert_text "Name can't be blank"
    end

    assert_text "Email can't be blank"
    assert_text 'Email is invalid'
  end
end
