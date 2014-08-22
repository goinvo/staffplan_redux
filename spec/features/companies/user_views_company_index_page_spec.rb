require 'rails_helper'

feature "user views company index page" do
  let(:user) { FactoryGirl.create(:confirmed_user) }
  let(:companies) { FactoryGirl.create_list(:company, 3) }

  before(:each) do
    sign_in_as(user)
  end

  scenario "with memberships to companies" do
    companies.each do |company|
      FactoryGirl.create(:membership, user: user, company: company)
    end

    within(".manage") do
      click_link "Companies"
    end

    companies.each do |company|
      expect(page).to have_content(company.name)
    end
  end

  scenario "with no memberships" do
    within(".manage") do
      click_link "Companies"
    end

    companies.each do |company|
      expect(page).to_not have_content(company.name)
    end

    expect(page).to have_content("Create a Company")
  end
end
