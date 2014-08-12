require 'rails_helper'

feature "user signs up" do
  before(:each) do
    user = FactoryGirl.build(:user)
  end

  scenario "with valid information" do
    visit root_path
    click_link "Sign Up"

    fill_in "First Name", with: user.first_name
    fill_in "Last Name", with: user.last_name
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    fill_in "Password confirmation", with: user.password
    click_button "Sign Up"

    expect(page).to have_content("You have successfully signed up")
    expect(page).to have_content(user.first_name)
    expect(page).to have_content(user.last_name)
  end

  scenario "with mismatching passwords" do
    visit new_user_registration_path

    fill_in "First Name", with: user.first_name
    fill_in "Last Name", with: user.last_name
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    fill_in "Password confirmation", with: "differentpassword"
    click_button "Sign Up"

    expect(page).to_not have_content("You have successfully signed up")
    expect(page).to have_content("Passwords don't match")
  end

  scenario "with an email that's already taken" do
    FactoryGirl.create(:user, email: user.email)

    visit new_user_registration_path

    fill_in "First Name", with: user.first_name
    fill_in "Last Name", with: user.last_name
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    fill_in "Password confirmation", with: user.password
    click_button "Sign Up"

    expect(page).to_not have_content("You have successfully signed up")
    expect(page).to have_content("Email is already taken")
  end

  scenario "with blank fields" do
    visit new_user_registration_path

    click_button "Sign Up"

    expect(page).to_not have_content("You have successfully signed up")
    expect(page).to have_content("can't be blank")
  end
end
