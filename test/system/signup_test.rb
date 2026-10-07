# frozen_string_literal: true

require 'test_helper'

class SignupTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  def assert_stripe_ids(registration, customer:, subscription:)
    company = registration.reload.user.current_company

    assert_equal customer, company.stripe_id
    assert_equal subscription, company.subscription.stripe_id
  end

  # Confirms a registration end to end: the request runs Stripe::CreateCustomerJob
  # against the recorded Stripe responses, then lands on the new user's StaffPlan
  def confirm_registration(registration, cassette:)
    VCR.use_cassette("Signing_up_for_StaffPlan/when_confirming_a_registration/when_registration_is_successful/#{cassette}") do
      perform_enqueued_jobs do
        visit register_registration_path(registration, token: registration.token)

        assert_current_path(%r{\A/people/\d+\z})
      end
    end
  end

  def fill_in_registration(company_name: Faker::Company.name, name: Faker::Name.name, email: Faker::Internet.email)
    visit new_registration_path
    fill_in 'registration[company_name]', with: company_name
    fill_in 'registration[name]', with: name
    fill_in 'registration[email]', with: email
  end

  def skip_browser_validation
    execute_script("document.querySelectorAll('form').forEach((form) => { form.noValidate = true })")
  end

  test 'the registration form has company name, name, and email fields' do
    visit new_registration_path

    assert_field 'registration[company_name]'
    assert_field 'registration[name]'
    assert_field 'registration[email]'
  end

  # the inputs are marked required, so turn off browser validation to reach the server-side errors
  test 'requires a name' do
    fill_in_registration(name: '')
    skip_browser_validation
    click_button 'Create account'

    assert_text "What's your name? You'll be the first person in your new account, you can add co-workers later."
    assert_css 'input.text-red-900'
  end

  test 'requires an email' do
    fill_in_registration(email: '')
    skip_browser_validation
    click_button 'Create account'

    assert_text 'Please provide a valid email address.'
    assert_css 'input.text-red-900'
  end

  test 'creates a new registration' do
    name = Faker::Name.name
    email = Faker::Internet.email
    fill_in_registration(name:, email:)

    assert_difference -> { Registration.count }, 1 do
      click_button 'Create account'

      assert_current_path auth_sign_in_path
    end

    registration = Registration.last

    assert_equal name, registration.name
    assert_equal email, registration.email
  end

  test 'emails the user a link to confirm their account' do
    fill_in_registration

    assert_difference -> { ActionMailer::Base.deliveries.count }, 1 do
      click_button 'Create account'

      assert_current_path auth_sign_in_path
    end

    email = ActionMailer::Base.deliveries.last

    assert_equal 1, Registration.count
    assert_equal 'Welcome to StaffPlan', email.subject
    assert_equal [Registration.last.email], email.to
  end

  test 'redirects the user to the sign in page' do
    fill_in_registration
    click_button 'Create account'

    assert_current_path auth_sign_in_path
  end

  test 'tells the user to check their email' do
    fill_in_registration
    click_button 'Create account'

    assert_text 'Thanks for your interest in StaffPlan! Check your e-mail for next steps on how to confirm your account.'
  end

  test 'confirming a registration signs the user in' do
    registration = create(:registration)

    confirm_registration(registration, cassette: 'should_confirm_the_registration_and_sign_the_user_in')

    assert_equal "/people/#{User.find_by!(email: registration.email).id}", page.current_path
    assert_stripe_ids(registration, customer: 'cus_VOhFZNZ36afIFD', subscription: 'sub_1UNtqYBLjyMcgacQmdIqVtlV')
  end

  test 'confirming a registration marks it as registered' do
    registration = create(:registration)

    confirm_registration(registration, cassette: 'should_mark_the_registration_as_having_registered_')

    assert_predicate registration.reload, :registered?
    assert_stripe_ids(registration, customer: 'cus_VOhENioP2BplKY', subscription: 'sub_1UNtqUBLjyMcgacQOtGIOWJu')
  end

  test 'confirming a registration creates a user for it' do
    registration = create(:registration)

    confirm_registration(registration, cassette: 'should_create_a_new_User_record_for_the_registration')

    assert_equal 1, User.count
    assert_equal registration.name, User.last.name
    assert_equal registration.email, User.last.email
    assert_stripe_ids(registration, customer: 'cus_VOhF9gmrbcwLFw', subscription: 'sub_1UNtqXBLjyMcgacQwJp3X6rH')
  end

  test 'an invalid registration token redirects to sign in' do
    registration = create(:registration)

    visit register_registration_path(registration, token: 'invalid')

    assert_current_path auth_sign_in_path
    assert_text 'Sorry, that link is invalid.'
  end

  test 'an invalid registration token does not create a user' do
    registration = create(:registration)

    visit register_registration_path(registration, token: 'invalid')

    assert_current_path auth_sign_in_path
    assert_equal 0, User.count
  end

  test 'a registration that has already been used redirects to sign in' do
    registration = create(:registration, registered_at: Time.current)

    visit register_registration_path(registration, token: registration.token)

    assert_current_path auth_sign_in_path
    assert_text 'Sorry, that link is invalid.'
  end
end
