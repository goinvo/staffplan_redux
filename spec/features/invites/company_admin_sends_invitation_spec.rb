require 'rails_helper'

feature "company admin sends invitation" do
  let(:user) { FactoryGirl.create(:confirmed_user) }
  let(:user2) { FactoryGirl.create(:confirmed_user) }
  let(:company) { FactoryGirl.create(:company) }
  let(:invite) { FactoryGirl.build(:invite) }

  before(:each) do
    FactoryGirl.create(:membership, user: user, company: company, permissions: [:admin])
    user.current_company = company
    user.save
    sign_in_as(user)
    within(".manage") do
      click_link "Company Invitations"
    end
    click_link "Send an invitation"
    clear_emails
  end

  scenario "to non-existent user" do
    fill_in "Email", with: invite.email
    click_button "Send Invitation"

    expect(Invite.count).to eq(1)
    expect(email_count).to eq(1)
    expect(open_email(invite.email)).to have_content("You can sign up to accept this invitation.")
    expect(page).to have_content("Your invitation was successfully sent")
  end

  scenario "to registered user" do
    fill_in "Email", with: user2.email
    clear_emails
    click_button "Send Invitation"

    expect(Invite.count).to eq(1)
    expect(email_count).to eq(1)
    expect(open_email(user2.email)).to have_content("Sign in to accept this invitation.")
    expect(page).to have_content("Your invitation was successfully sent")
  end

  scenario "to already existing employee" do
    user3 = FactoryGirl.create(:confirmed_user)
    FactoryGirl.create(:membership, company: company, user: user3)
    clear_emails

    fill_in "Email", with: user3.email
    click_button "Send Invitation"

    expect(Invite.count).to eq(0)
    expect(email_count).to eq(0)
    expect(page).to have_content("Employee with this email already exists for this company.")
  end

  scenario "to email where invite already exists for that company" do
    FactoryGirl.create(:invite, email: user2.email, company: company, sender: user)

    fill_in "Email", with: user2.email
    click_button "Send Invitation"

    expect(Invite.count).to eq(1)
    expect(page).to have_content("This invite already exists.")
  end

  scenario "with blank fields" do
    click_button "Send Invitation"

    expect(Invite.count).to eq(0)
    expect(page).to have_content("Email can't be blank")
  end
end
