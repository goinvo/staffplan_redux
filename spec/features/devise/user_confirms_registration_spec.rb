require 'rails_helper'

feature "user confirms registration" do
  scenario "succesfully, with valid token" do
    user = FactoryGirl.create(:user)

    open_email(user.email)
    current_email.click_link("Confirm my account")

    expect(page).to have_content("Your account was successfully confirmed.")
  end

  scenario "with invalid token" do
    user = FactoryGirl.create(:user)
    clear_emails

    visit "/users/confirmation?thisisnotatoken"

    expect(page).to have_content("Confirmation token can't be blank") #need to change en.yml message for this

    fill_in "Email", with: user.email
    click_button "Resend confirmation instructions"

    expect(email_count).to eq(1)
    expect(page).to have_content("You will receive an email with instructions about how to confirm your account in a few minutes.")
  end
end
