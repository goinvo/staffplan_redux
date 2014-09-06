require 'rails_helper'

feature "non-admin can't access management page for company invites" do
  let(:user) { FactoryGirl.create(:confirmed_user) }
  let(:company) { FactoryGirl.create(:company) }

  before(:each) do
    FactoryGirl.create(:membership, user: user, company: company)
    user.current_company = company
    user.save
    sign_in_as(user)
  end

  scenario "link doesn't display" do
    expect(page).to_not have_content("Company Invitations")
  end

  scenario "denied from direct url" do
    expect { visit company_invites_path(company) }.to raise_error(ActionController::RoutingError)
  end
end
