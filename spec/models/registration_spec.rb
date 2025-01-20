require 'rails_helper'

RSpec.describe Registration, type: :model do
  context "validations" do
    it { should validate_presence_of(:company_name) }
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
        expect(Stripe::CreateCustomerJob).to receive(:perform_later)

        registration.register!

        expect { registration.reload.register! }.to raise_error(Registration::RegistrationNotAvailableError)
      end

      it "calls CreateNewCompany" do
        registration = create(:registration)
        expect_any_instance_of(CreateNewCompany).to receive(:call)
        registration.register!
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
