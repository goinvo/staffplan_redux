require 'rails_helper'

feature "user creates a new project" do
  let(:user) { FactoryGirl.create(:confirmed_user)}
  let(:company) { FactoryGirl.create(:company) }

  before(:each) do
    client = FactoryGirl.create(:client, company: company)
    FactoryGirl.create(:membership, user: user, company: company)
    sign_in_as(user)
  end

  scenario "with valid information" do

  end

end
