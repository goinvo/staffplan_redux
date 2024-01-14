require 'rails_helper'

RSpec.describe Registration, type: :model do
  context "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:ip_address) }

    describe "expired?" do
      it "returns true if expires_at is in the past" do
        registration = build(:registration, expires_at: 1.day.ago)
        expect(registration.expired?).to eq(true)
      end

      it "returns false if expires_at is in the future" do
        registration = build(:registration, expires_at: 1.day.from_now)
        expect(registration.expired?).to eq(false)
      end
    end

    describe "available?" do
      it "returns true if expires_at is in the future" do
        registration = build(:registration, expires_at: 1.day.from_now)
        expect(registration.available?).to eq(true)
      end

      it "returns false if expires_at is in the past" do
        registration = build(:registration, expires_at: 1.day.ago)
        expect(registration.available?).to eq(false)
      end
    end

    describe "register!" do
      it "raises RegistrationNotAvailableError if claimed?" do
        registration = create(:registration)
        registration.register!
        expect { registration.register! }.to raise_error(Registration::RegistrationNotAvailableError)
      end

      it "creates a company" do
        registration = create(:registration)
        expect { registration.register! }.to change(Company, :count).by(1)
      end

      it "creates a user" do
        registration = create(:registration)
        expect { registration.register! }.to change(User, :count).by(1)
      end

      it "associates the user with the company" do
        registration = create(:registration)
        registration.register!
        user = registration.user
        expect(user.companies.length).to eq(1)
        expect(user.companies.first.name).to match(user.name)
      end

      it "sets the user's name and email from the registration" do
        registration = create(:registration)
        registration.register!
        expect(registration.user.name).to eq(registration.name)
        expect(registration.user.email).to eq(registration.email)
      end

      it "sets the user's role to owner" do
        registration = create(:registration)
        registration.register!
        expect(registration.user.memberships.first.role).to eq("owner")
      end

      it "sets the user's status to active" do
        registration = create(:registration)
        registration.register!
        expect(registration.user.memberships.first.status).to eq("active")
      end

      it "sets the registration's registered_at timestamp" do
        registration = create(:registration)
        registration.register!
        expect(registration.registered_at).to be_present
      end
    end

    describe "registered?" do
      it "returns true if registered_at is present" do
        registration = build(:registration, registered_at: Time.current)
        expect(registration.registered?).to eq(true)
      end

      it "returns false if registered_at is blank" do
        registration = build(:registration, registered_at: nil)
        expect(registration.registered?).to eq(false)
      end
    end

    describe "to_param" do
      it "returns the identifier" do
        registration = create(:registration)
        expect(registration.to_param).to eq(registration.identifier)
      end
    end
  end
end
