require 'rails_helper'

before(:each) do
  user = FactoryGirl.create(:confirmed_user)
  sign_in_as(user)
end

feature "user edits: " do
  scenario "account information successfully" do
    user2 = FactoryGirl.build(:confirmed_user)

    within(".manage") do
      click_link "Account"
    end

    fill_in "First name", with: user2.first_name
    fill_in "Last name", with: user2.last_name
    fill_in "Email", with: user2.email
    fill_in "Current password", with: user.password
    click_button "Update"

    expect(page).to have_content("You updated your account successfully")
    user.reload
    expect(user.email).to eq(user2.email)
    expect(user.first_name).to eq(user2.first_name)
    expect(user.last_name).to eq(user2.last_name)
  end

  scenario "password successfully" do
    within(".manage") do
      click_link "Account"
    end

    fill_in "Password", with: "newpassword123"
    fill_in "Password confirmation", with: "newpassword123"
    fill_in "Current password", with: user.password
    click_button "Update"

    expect(page).to have_content("You updated your account successfully")
    user.reload
    click_link "Sign out"

    fill_in "Email", with: user.email
    fill_in "Password", with: "newpassword123"
    click_button "Sign in"

    expect(page).to have_content("signed in")
  end

  scenario "account information with blank fields" do
    within(".manage") do
      click_link "Account"
    end

    fill_in "Email", with: ""
    fill_in "Current password", with: user.password
    click_button "Update"

    expect(page).to have_content("Email can't be blank")
  end

  scenario "account information with wrong password" do
    within(".manage") do
      click_link "Account"
    end

    click_button "Update"

    expect(page).to have_content("Current password can't be blank")
  end
end
