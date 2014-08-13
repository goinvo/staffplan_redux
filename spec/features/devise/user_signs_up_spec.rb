require 'rails_helper'

feature "user signs up" do
  let(:user) { FactoryGirl.build(:user) }
  let(:company) { FactoryGirl.build(:company) }

  scenario "with valid information" do
    visit root_path
    click_link "Sign up"

    fill_in "First name", with: user.first_name
    fill_in "Last name", with: user.last_name
    fill_in "Your Company", with: company.name
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    fill_in "Password confirmation", with: user.password
    click_button "Sign up"

    expect(page).to have_content("A message with a confirmation link has been sent to your email address.")
  end

  scenario "with mismatching passwords" do
    visit new_user_registration_path

    fill_in "First name", with: user.first_name
    fill_in "Last name", with: user.last_name
    fill_in "Your Company", with: company.name
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    fill_in "Password confirmation", with: "differentpassword"
    click_button "Sign up"

    expect(page).to_not have_content("You have successfully signed up")
    expect(page).to have_content("Password confirmation doesn't match")
  end

  scenario "with an email that's already taken" do
    FactoryGirl.create(:user, email: user.email)

    visit new_user_registration_path

    fill_in "First name", with: user.first_name
    fill_in "Last name", with: user.last_name
    fill_in "Your Company", with: company.name
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    fill_in "Password confirmation", with: user.password
    click_button "Sign up"

    expect(page).to_not have_content("You have successfully signed up")
    expect(page).to have_content("Email has already been taken")
  end

  scenario "with blank fields" do
    visit new_user_registration_path

    click_button "Sign up"

    expect(page).to_not have_content("You have successfully signed up")
    expect(page).to have_content("can't be blank")
  end
end
