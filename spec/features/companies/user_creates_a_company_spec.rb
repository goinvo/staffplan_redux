require 'rails_helper'

feature "user creates a company" do
  let(:user) { FactoryGirl.create(:confirmed_user) }
  let(:company) { FactoryGirl.build(:company) }

  before(:each) do
    sign_in_as(user)
  end

  scenario "with valid information" do
    visit root_path
    click_link "Create a Company"

    fill_in "Company Name", with: company.name
    click_button "Create company"

    expect(Company.count).to eq(1)
    expect(page).to have_content("Your company was successfully created.")
  end

  scenario "with a company name that already exists" do
    existing_company = FactoryGirl.create(:company)
    visit new_company_path

    fill_in "Company Name", with: existing_company.name
    click_button "Create company"

    expect(Company.count).to eq(0)
    expect(page).to_not have_content("Your company was successfully created.")
    expect(page).to have_content("Name has already been taken.")
  end

  scenario "with blank fields" do
    visit new_company_path

    click_button "Create company"

    expect(Company.count).to eq(0)
    expect(page).to_not have_content("Your company was successfully created.")
    expect(page).to have_content("can't be blank")
  end
end
