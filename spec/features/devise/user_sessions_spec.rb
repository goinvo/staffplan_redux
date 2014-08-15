require 'rails_helper'

feature "user sessions: " do
  let(:user) { FactoryGirl.create(:confirmed_user) }

  scenario "signs in successfully" do
    visit root_path

    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Sign in"

    expect(page).to have_content("Signed in successfully")
  end

  scenario "signs in with invalid email" do
    visit root_path

    fill_in "Email", with: "doesnotexist@example.com"
    fill_in "Password", with: user.password
    click_button "Sign in"

    expect(page).to_not have_content("Signed in successfully")
    expect(page).to have_content("Invalid email or password")
  end

  scenario "signs in with invalid password" do
    visit root_path

    fill_in "Email", with: user.email
    fill_in "Password", with: "wrongpassword"
    click_button "Sign in"

    expect(page).to_not have_content("Signed in successfully")
    expect(page).to have_content("Invalid email or password")
  end

  scenario "signs in with blank fields" do
    visit root_path
    click_button "Sign in"

    expect(page).to_not have_content("Signed in successfully")
    expect(page).to have_content("Invalid email or password")
  end

  scenario "signs in with unconfirmed account" do
    unconfirmed_user = FactoryGirl.create(:user)

    visit root_path
    fill_in "Email", with: unconfirmed_user.email
    fill_in "Password", with: unconfirmed_user.password
    click_button "Sign in"

    expect(page).to have_content("You have to confirm your account before continuing.")
  end

  scenario "signs out successfully" do
    sign_in_as(user)

    click_link "Sign Out"

    expect(page).to have_content("Signed out successfully")
  end

end
