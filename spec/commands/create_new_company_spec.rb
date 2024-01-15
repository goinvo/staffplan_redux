require 'rails_helper'

RSpec.describe CreateNewCompany do

  before do
    Sidekiq::Testing.inline!
  end

  describe "#call", :vcr do
    it "creates a company" do
      registration = create(:registration)
      expect { CreateNewCompany.new(registration).call }.to change(Company, :count).by(1)
    end

    it "creates a user" do
      registration = create(:registration)
      expect { CreateNewCompany.new(registration).call }.to change(User, :count).by(1)
    end

    it "associates the user with the company" do
      registration = create(:registration)
      CreateNewCompany.new(registration).call
      user = registration.reload.user
      expect(user.companies.length).to eq(1)
      expect(user.companies.first.name).to match(user.name)
    end

    it "sets the user's name and email from the registration" do
      registration = create(:registration)
      CreateNewCompany.new(registration).call
      expect(registration.user.name).to eq(registration.name)
      expect(registration.user.email).to eq(registration.email)
    end

    it "sets the user's role to owner" do
      registration = create(:registration)
      CreateNewCompany.new(registration).call
      expect(registration.user.memberships.first.role).to eq("owner")
    end

    it "sets the user's status to active" do
      registration = create(:registration)
      CreateNewCompany.new(registration).call
      expect(registration.user.memberships.first.status).to eq("active")
    end

    it "sets the registration's registered_at timestamp" do
      registration = create(:registration)
      CreateNewCompany.new(registration).call
      expect(registration.registered_at).to be_present
    end

    it "creates a stripe customer" do
      registration = create(:registration)
      command = CreateNewCompany.new(registration)
      command.call
      expect(command.company.reload.stripe_id).to be_present
    end
  end
end