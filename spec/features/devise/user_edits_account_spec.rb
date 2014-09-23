require 'rails_helper'

feature "user edits: " do
  let(:user) { FactoryGirl.create(:confirmed_user) }

  before(:each) do
    sign_in_as(user)

    within(".manage") do
      click_link "Profile"
    end
  end

  scenario "account information successfully" do
    user2 = FactoryGirl.build(:confirmed_user)

    fill_in "First name", with: user2.first_name
    fill_in "Last name", with: user2.last_name
    fill_in "Email", with: user2.email
    fill_in "Current password", with: user.password
    click_button "Update"

    expect(page).to have_content("You updated your account successfully")
  end

  scenario "password successfully" do

    fill_in "Password", with: "newpassword123"
    fill_in "Password confirmation", with: "newpassword123"
    fill_in "Current password", with: user.password
    click_button "Update"

    expect(page).to have_content("You updated your account successfully")
    user.reload
    click_link "Sign Out"

    fill_in "Email", with: user.email
    fill_in "Password", with: "newpassword123"
    click_button "Sign in"

    expect(page).to have_content("Signed in successfully")
  end

  scenario "account information with blank fields" do

    fill_in "Email", with: ""
    fill_in "Current password", with: user.password
    click_button "Update"

    expect(page).to have_content("Email can't be blank")
  end

  scenario "account information with wrong password" do
    click_button "Update"

    expect(page).to have_content("Current password can't be blank")
  end
end
