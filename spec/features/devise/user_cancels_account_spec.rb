require 'rails_helper'

feature "user cancels account" do
  scenario "successfully" do
    user = FactoryGirl.create(:confirmed_user)
    sign_in_as(user)

    within(".manage") do
      click_link "Profile"
    end

    click_button "Cancel my account"

    expect(User.count).to eq(0)
    expect(page).to have_content("Bye! Your account was successfully cancelled. We hope to see you again soon.")
  end
end
