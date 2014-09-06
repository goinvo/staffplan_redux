require 'rails_helper'

feature "user creates a new project" do
  let(:user) { FactoryGirl.create(:confirmed_user) }
  let(:company) { FactoryGirl.create(:company) }
  let(:project) { FactoryGirl.build(:project) }

  before(:each) do
    @client = FactoryGirl.create(:client, company: company)
    FactoryGirl.create(:membership, user: user, company: company, permissions: [:admin])
    user.current_company = company
    user.save
    sign_in_as(user)

    within(".manage") do
      click_link "Clients"
    end

    click_link @client.name

    click_link "Create a project"
  end

  scenario "with valid information" do
    fill_in "project_name", with: project.name
    click_button "Create Project"

    expect(Project.count).to eq(1)
    expect(page).to have_content("The project was created successfully")
  end

  scenario "with existing project name" do
    existing_project = FactoryGirl.create(:project, client: @client)

    fill_in "project_name", with: existing_project.name
    click_button "Create Project"

    expect(Project.count).to eq(1)
    expect(page).to have_content("Name has already been taken")
  end

  scenario "with blank fields" do
    click_button "Create Project"

    expect(Project.count).to eq(0)
    expect(page).to have_content("Name can't be blank")
  end

end
