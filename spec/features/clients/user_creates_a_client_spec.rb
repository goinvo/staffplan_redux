require 'rails_helper'
let(:user) { FactoryGirl.create(:confirmed_user)}
let(:company) { FactoryGirl.create(:company) }
let(:client) { FactoryGirl.build(:client) }
FactoryGirl.create(:membership, user: user, company: company)

feature "user creates a new client" do
  scenario "with valid information" do
    visit root_path
    click_link "Add a Client"

    fill_in "Name", with: client.name
    fill_in "Description", with: client.description
    click_button "Create Client"

    expect(Client.count).to eq(1)
    expect(page).to have_content("Created new client successfully")
  end
end
