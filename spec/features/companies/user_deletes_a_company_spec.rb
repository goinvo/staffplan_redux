require 'rails_helper'

feature "user edits a company" do
  let(:user) { FactoryGirl.create(:confirmed_user) }
  let(:company) { FactoryGirl.create(:company) }

  before(:each) do
    FactoryGirl.create(:membership, user: user, company: company, permissions: [:admin])
    sign_in_as(user)

    within(".manage") do
      click_link "Companies"
    end

    click_link company.name

    click_link "Edit"
  end

  scenario "successfully" do
    click_link "Delete Company"

    expect(Company.count).to eq(0)
    expect(page).to have_content("Your company was deleted")
    expect(page).to_not have_content(company.name)
  end
end
