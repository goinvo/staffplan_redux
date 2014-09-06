require 'rails_helper'

feature "company admin deletes invitation" do
  let(:user) { FactoryGirl.create(:confirmed_user) }
  let(:company) { FactoryGirl.create(:company) }

  before(:each) do
    FactoryGirl.create(:membership, user: user, company: company, permissions: [:admin])
    FactoryGirl.create(:invite, sender: user, company: company)
    user.current_company = company
    user.save
    sign_in_as(user)
  end

  scenario "successfully" do
    visit company_invites_path(company)
    click_link "Delete"

    expect(Invite.count).to eq(0)
    expect(page).to have_content("Invitation deleted")
  end
end
