# frozen_string_literal: true

require 'test_helper'

class SignInTest < ActionDispatch::IntegrationTest
  TOKEN = '123456'

  setup do
    @user = create(:user)
  end

  test 'renders the sign in page' do
    get auth_sign_in_path

    assert_response :ok
  end

  test 'signs in through the magic link and redirects to the staffplan' do
    confirm_url = request_magic_link

    get confirm_url

    assert_redirected_to '/'

    follow_redirect!

    assert_redirected_to "/people/#{@user.id}"
  end

  test 'signs in by entering the token and redirects to the staffplan' do
    request_magic_link

    patch verify_auth_sign_in_path(@user.passwordless_sessions.last.identifier),
          params: { passwordless: { token: TOKEN } }

    assert_redirected_to '/'
  end

  test 'redirects back to the page the user originally requested' do
    get settings_profile_path

    assert_redirected_to auth_sign_in_path

    get request_magic_link

    assert_redirected_to settings_profile_path

    follow_redirect!

    assert_response :ok
  end

  test 'sends the user to the staffplan when visiting sign in while signed in' do
    get request_magic_link

    get auth_sign_in_path

    assert_redirected_to "/people/#{@user.id}"
  end

  private

  def request_magic_link
    Passwordless.config.token_generator.stub :call, TOKEN do
      post sign_in_path, params: { passwordless: { email: @user.email } }
    end

    assert_response :redirect

    confirm_auth_sign_in_path(@user.passwordless_sessions.last.identifier, TOKEN)
  end
end
