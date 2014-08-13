require 'rails_helper'
let(:user) { FactoryGirl.create(:confirmed_user) }

before { clear_emails }

feature "user requests password reset instructions" do
  scenario "successfully, with valid email" do
    visit root_path
    click_link "Forgot your password?"
    fill_in "Email", with: user.email
    click_button "Send me reset password instruction"

    expect(email_count).to eq(1)
    expect(page).to have_content("You will receive an email with instructions on how to reset your password in a few minutes.")

    open_email(last_email)
    current_email.click_link("Change my password")
  end

  scenario "and supplies invalid password reset token" do
    visit "/users/password/edit?reset_password_token=thisisnotatoken"
    fill_in "New password", with: "password123"
    fill_in "New password confirmation", with: "password123"
    click_button "Change my password"

    expect(page).to have_content("Reset password token is invalid")
  end

  scenario "with nonexistent email" do
    visit new_user_password_path
    fill_in "Email", with: "nonexistentemail@example.com"
    click_button "Send me reset password instruction"

    expect(email_count).to eq(0)
    expect(page).to have_content("Email not found")
  end
end
