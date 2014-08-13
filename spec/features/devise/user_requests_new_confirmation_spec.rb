require 'rails_helper'

feature "user requests new confirmation instructions" do
  scenario "with valid email" do
    user = FactoryGirl.create(:user)
    clear_emails

    visit root_path
    click_link "Didn't receive confirmation instructions?"

    fill_in "Email", with: user.email
    click_button "Resend confirmation instructions"

    expect(email_count).to eq(1)
    expect(page).to have_content("You will receive an email with instructions about how to confirm your account in a few minutes.")
  end

  scenario "with email that is already confirmed" do
    user = FactoryGirl.create(:confirmed_user)
    clear_emails

    visit new_user_confirmation_path
    fill_in "Email", with: user.email
    click_button "Resend confirmation instructions"

    expect(email_count).to eq(0)
    expect(page).to have_content("Email was already confirmed, please try signing in")
  end

  scenario "with nonexistent email" do

    visit new_user_confirmation_path
    fill_in "Email", with: "nonexistentemail@example.com"
    click_button "Resend confirmation instructions"

    expect(email_count).to eq(0)
    expect(page).to have_content("Email not found")
  end
end
