require 'rails_helper'

feature "user responds to an invite:" do
  let(:user) { FactoryGirl.create(:confirmed_user) }
  let(:user2) { FactoryGirl.create(:confirmed_user) }
  let(:company) { FactoryGirl.create(:company) }

  before(:each) do
    @invite = FactoryGirl.create(:invite, email: user.email, company: company, sender: user2)
  end

  scenario "accepts successfully" do
    sign_in_as(user)
    clear_emails
    within(:css, "h1") do
      expect(page).to have_content("Invitations")
    end
    click_link "Accept"

    @invite.reload
    expect(@invite.aasm.current_state).to eq(:accepted)
    expect(Membership.count).to eq(1)
    membership = Membership.last
    expect(membership.user).to eq(user)
    expect(membership.company).to eq(company)
    expect(email_count).to eq(1)
    expect(open_email(user2.email)).to have_content("#{user.full_name} has accepted your invitation to join #{company.name} on StaffPlan.")
    expect(page).to have_content("Accepted invitation")
  end

  scenario "declines successfully" do
    sign_in_as(user)
    clear_emails
    within(:css, "h1") do
      expect(page).to have_content("Invitations")
    end
    click_link "Decline"

    @invite.reload
    expect(@invite.aasm.current_state).to eq(:declined)
    expect(email_count).to eq(1)
    expect(open_email(user2.email)).to have_content("#{user.full_name} has declined your invitation to join #{company.name} on StaffPlan.")
    expect(page).to have_content("Declined invitation")
  end

  scenario "doesn't get taken to invite page if they belong to a company already" do
    FactoryGirl.create(:membership, user: user, company: FactoryGirl.create(:company))
    sign_in_as(user)
    clear_emails

    expect(page).to_not have_content(:css, "h1")
  end
end
