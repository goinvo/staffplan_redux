require 'rails_helper'

feature "user sessions: " do
  before(:each) do
    user = FactoryGirl.create(:user)
  end

  scenario "signs in successfully" do
    visit root_path

    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Sign In"

    expect(page).to have_content("signed in")
    expect(page).to have_content(user.first_name)
    expect(page).to have_content(user.last_name)
  end

  scenario "signs in with invalid email" do
    visit root_path

    fill_in "Email", with: "doesnotexist@example.com"
    fill_in "Password", with: user.password
    click_button "Sign In"

    expect(page).to_not have_content("signed in")
    expect(page).to have_content("Wrong email or password")
  end

  scenario "signs in with invalid password" do
    visit root_path

    fill_in "Email", with: user.email
    fill_in "Password", with: "wrongpassword"
    click_button "Sign In"

    expect(page).to_not have_content("signed in")
    expect(page).to have_content("Wrong email or password")
  end

  scenario "signs in with blank fields" do
    visit root_path

    click_button "Sign In"

    expect(page).to_not have_content("signed in")
    expect(page).to have_content("can't be blank")
  end

  scenario "signs out successfully" do
    sign_in_as(user)

    click_link "Sign Out"

    expect(page).to have_content("signed out")
    expect(page).to_not have_content(user.first_name)
    expect(page).to_not have_content(user.last_name)
  end

end
