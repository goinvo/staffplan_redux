require 'test_helper'

class AuthenticationsTest < ApplicationSystemTestCase
  describe "Authentication" do
    describe "when user is not signed in" do
      it "redirects to sign in page" do
        visit root_path
        assert_current_path auth_sign_in_path
      end
    end

    describe "when an email does not exist" do
      it "does not show the user that we couldn't find their e-mail address" do
        visit root_path
        fill_in "passwordless[email]", with: Faker::Internet.email
        click_button "Sign in"
        assert_text "We've sent you an email with a secret token"
      end
    end

    describe "when an email exists" do
      it "sends the user an email with a sign in link" do
        user = create(:user)
        visit root_path
        fill_in "passwordless[email]", with: user.email

        assert_difference('ActionMailer::Base.deliveries.count', 1) do
          click_button "Sign in"
        end

        assert_text "We've sent you an email with a secret token"
      end

      it "redirects the user to the token entry page" do
        user = create(:user)
        visit root_path
        fill_in "passwordless[email]", with: user.email
        click_button "Sign in"
        assert_current_path verify_auth_sign_in_path(user.passwordless_sessions.last.identifier)
      end

      it "signs them in after successfully entering the token" do
        token = "123456"
        Passwordless.config.token_generator.stub :call, token do
          user = create(:user)
          visit root_path
          fill_in "passwordless[email]", with: user.email
          click_button "Sign in"
          fill_in "passwordless[token]", with: token
          click_button "Confirm"
          assert_current_path "/people/#{user.id}"
        end
      end

      it "signs them in after clicking the link in the email" do
        token = "123456"
        Passwordless.config.token_generator.stub :call, token do
          user = create(:user)
          visit root_path
          fill_in "passwordless[email]", with: user.email
          click_button "Sign in"

          # click the link in the email
          visit confirm_auth_sign_in_path(user.passwordless_sessions.last.identifier, token)
          assert_current_path "/people/#{user.id}"
        end
      end
    end

    describe "when the user enters an invalid token" do
      it "shows the user an error that their token is invalid" do
        user = create(:user)
        visit root_path
        fill_in "passwordless[email]", with: user.email
        click_button "Sign in"
        fill_in "passwordless[token]", with: "bad token"
        click_button "Confirm"
        assert_text "Token is invalid"
      end
    end

    describe "when a user signs out" do
      it "redirects the user to the sign in page" do
        token = "123456"
        Passwordless.config.token_generator.stub :call, token do
          user = create(:user)
          visit root_path
          fill_in "passwordless[email]", with: user.email
          click_button "Sign in"
          fill_in "passwordless[token]", with: token
          click_button "Confirm"
          assert_current_path "/people/#{user.id}"

          # sign yourself out
          visit auth_sign_out_path

          # now visit the dashboard, see the login page
          visit dashboard_path
          assert_text "Please sign in"
        end
      end
    end
  end
end