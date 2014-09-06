require 'rails_helper'

feature "user edits a company" do
  let(:user) { FactoryGirl.create(:confirmed_user) }
  let(:company) { FactoryGirl.create(:company) }
  let(:company2) { FactoryGirl.build(:company) }
  let(:company3) { FactoryGirl.create(:company) }

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
    fill_in :company_name, with: company2.name
    click_button "Update Company"

    expect(page).to have_content("Your company was successfully updated")
    expect(page).to have_content(company2.name)
  end

  scenario "with already existent company name" do
    fill_in :company_name, with: company3.name
    click_button "Update Company"

    expect(page).to have_content("Couldn't update your company")
    expect(page).to have_content("Name has already been taken")
  end

  scenario "with blank fields" do
    fill_in :company_name, with: ""
    click_button "Update Company"

    expect(page).to have_content("Couldn't update your company")
    expect(page).to have_content("Name can't be blank")
  end
end
