require 'rails_helper'

feature "user creates a new client" do
  let(:user) { FactoryGirl.create(:confirmed_user)}
  let(:company) { FactoryGirl.create(:company) }
  let(:client) { FactoryGirl.build(:client) }

  before(:each) do
    FactoryGirl.create(:membership, user: user, company: company)
    #how do I do this??
    user.current_company = company
    user.save
    sign_in_as(user)
  end

  scenario "with valid information" do
    visit company_path(company)

    click_link "Add a client"

    fill_in "Name", with: client.name
    fill_in "Description", with: client.description
    click_button "Create Client"

    expect(Client.count).to eq(1)
    expect(Client.first.company).to eq(company)
    expect(page).to have_content("Created new client successfully")
  end

  scenario "with a client name that already exists" do
    existing_client = FactoryGirl.create(:client)

    visit new_client_path
    fill_in "Name", with: existing_client.name
    fill_in "Description", with: existing_client.description
    click_button "Create Client"

    expect(Client.count).to eq(0)
    expect(page).to have_content("Name has already been taken")
  end

  scenario "with blank fields" do
    visit new_client_path
    click_button "Create Client"

    expect(Client.count).to eq(0)
    expect(page).to have_content("Name can't be blank")
  end
end
