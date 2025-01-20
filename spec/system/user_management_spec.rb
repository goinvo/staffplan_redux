require 'rails_helper'

RSpec.describe "User Management", type: :system do
  describe "loading the company user management page" do
    it "shows the page to admins" do
      membership = create(:membership, role: Membership::ADMIN)
      passwordless_sign_in(membership.user)

      visit settings_users_url

      expect(page).to have_text(membership.user.name)
      expect(page).to have_link("New User")
    end

    it "shows the page to owners" do
      membership = create(:membership, role: Membership::OWNER)
      passwordless_sign_in(membership.user)

      visit settings_users_url

      expect(page).to have_text(membership.user.name)
      expect(page).to have_link("New User")
    end

    it "does not show the page to members" do
      membership = create(:membership, role: Membership::MEMBER)
      passwordless_sign_in(membership.user)

      visit settings_users_url

      expect(page).to have_current_path("/people/#{membership.user_id}")
    end
  end

  describe "adding a new user" do
    it "adds a new user" do
      membership = create(:membership, role: Membership::ADMIN)
      passwordless_sign_in(membership.user)

      visit settings_users_url
      click_link "New User"

      fill_in "Full name", with: Faker::Name.name
      fill_in "Email", with: Faker::Internet.email

      expect(Stripe::SyncCustomerSubscriptionJob).to receive(:perform_later)

      expect do
        click_button "Create"
      end.to change(User, :count).by(1)

      expect(page).to have_current_path(settings_users_path)
      expect(page).to have_text("User added successfully")
    end

    it "re-renders the form when there are errors" do
      membership = create(:membership, role: Membership::ADMIN)
      passwordless_sign_in(membership.user)

      visit settings_users_url
      click_link "New User"

      expect do
        click_button "Create"
      end.to change(User, :count).by(0)

      expect(page).to have_text("Name can't be blank")
      expect(page).to have_text("Email can't be blank")
      expect(page).to have_text("Email is invalid")
    end
  end
end
