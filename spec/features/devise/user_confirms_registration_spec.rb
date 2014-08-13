require 'rails_helper'

feature "user confirms registration" do
  scenario "succesfully, with valid token" do
    FactoryGirl.create(:user)

    open_email(last_email)
    current_email.click_link('Click here to confirm')

    expect(page).to have_content("Your account was successfully confirmed.")
  end

  scenario "with invalid token" do
    user = FactoryGirl.create(:user)
    clear_emails

    visit "/users/confirmation?thisisnotatoken"

    expect(page).to have_content("Invalid confirmation token") #need to change en.yml message for this

    fill_in "Email", with: user.email
    click_button "Resend confirmation instructions"

    expect(email_count).to eq(1)
    expect(page).to have_content("A message with a confirmation link has been sent to your email address.")
  end
end
