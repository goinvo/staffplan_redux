require 'rails_helper'

RSpec.describe "Signing up for StaffPlan", type: :system, vcr: true do
  context "when registering for StaffPlan" do
    describe "the registration form" do
      it "has a name and email field" do
        visit new_registration_path
        expect(page).to have_field("registration[name]")
        expect(page).to have_field("registration[email]")
      end
    end

    describe "when user enters in incomplete information" do
      # for modern browsers this should be a difficult state to achieve since the input fields
      # declare themselves as required.
      it "requires a name" do
        visit new_registration_path
        fill_in "registration[name]", with: ""
        fill_in "registration[email]", with: Faker::Internet.email

        click_button "Create account"

        expect(page).to have_content("What should we call you?")
        expect(page).to have_css("input.text-red-900")
      end

      it "requires an email" do
        visit new_registration_path
        fill_in "registration[name]", with: Faker::Name.name
        fill_in "registration[email]", with: ""

        click_button "Create account"

        expect(page).to have_content("Please provide a valid email address.")
        expect(page).to have_css("input.text-red-900")
      end
    end

    describe "when providing valid information" do
      it "should create a new registration" do
        visit new_registration_path
        fill_in "registration[name]", with: Faker::Name.name
        fill_in "registration[email]", with: Faker::Internet.email

        expect {
          click_button "Create account"
        }.to change { Registration.count }.by(1)

        expect(Registration.count).to eq(1)
        registration = Registration.last
        expect(registration.name).to eq(Registration.last.name)
        expect(registration.email).to eq(Registration.last.email)
      end

      it "should send the user an email with a link to confirm their account" do
        visit new_registration_path
        fill_in "registration[name]", with: Faker::Name.name
        fill_in "registration[email]", with: Faker::Internet.email

        expect {
          click_button "Create account"
        }.to change { ActionMailer::Base.deliveries.count }.by(1)

        email = ActionMailer::Base.deliveries.last
        expect(Registration.count).to eq(1)
        registration = Registration.last
        expect(email.subject).to eq("Welcome to StaffPlan")
        expect(email.to).to eq([registration.email])
      end

      it "should redirect the user to the sign in page" do
        visit new_registration_path
        fill_in "registration[name]", with: Faker::Name.name
        fill_in "registration[email]", with: Faker::Internet.email

        click_button "Create account"

        expect(page).to have_current_path(auth_sign_in_path)
      end

      it "should show the user a message that they need to check their email" do
        visit new_registration_path
        fill_in "registration[name]", with: Faker::Name.name
        fill_in "registration[email]", with: Faker::Internet.email

        click_button "Create account"

        expect(page).to have_content("Thanks for your interest in StaffPlan! Check your e-mail for next steps on how to confirm your account.")
      end
    end
  end

  context "when confirming a registration" do
    describe "when registration is successful" do
      it "should confirm the registration and sign the user in" do
        registration = create(:registration)
        visit register_registration_path(registration.reload, token: registration.token)

        expect(page).to have_current_path(root_path)
        expect(page).to have_content("Thanks for registering! You're now signed in.")
      end

      it "should mark the registration as having registered?" do
        registration = create(:registration)
        visit register_registration_path(registration, token: registration.token)

        expect(registration.reload.registered?).to be(true)
      end

      it "should create a new User record for the registration" do
        registration = create(:registration)
        visit register_registration_path(registration, token: registration.token)

        expect(User.count).to eq(1)
        user = User.last
        expect(user.name).to eq(registration.name)
        expect(user.email).to eq(registration.email)
      end
    end

    describe "when registration is unsuccessful" do
      it "should redirect the user to the sign in page" do
        registration = create(:registration)
        allow_any_instance_of(Registration).to receive(:token_digest).and_return("invalid")
        visit register_registration_path(registration, token: registration.token)

        expect(page).to have_current_path(auth_sign_in_path)
        expect(page).to have_content("Sorry, that link is invalid.")
      end

      it "does not create a new User record" do
        registration = create(:registration)
        allow_any_instance_of(Registration).to receive(:token_digest).and_return("invalid")
        visit register_registration_path(registration, token: registration.token)

        expect(User.count).to eq(0)
      end
    end
  end

  context "when a registration has already been used" do
    it "should redirect the user to the sign in page" do
      registration = create(:registration, registered_at: Time.current)
      visit register_registration_path(registration, token: registration.token)

      expect(page).to have_current_path(auth_sign_in_path)
      expect(page).to have_content("Sorry, that link is invalid.")
    end
  end
end
