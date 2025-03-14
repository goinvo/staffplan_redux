require 'rails_helper'

RSpec.describe CreateNewCompany do
  describe "#call" do
    it "creates a company" do
      registration = create(:registration)
      expect(Stripe::CreateCustomerJob).to receive(:perform_later)
      expect {
        CreateNewCompany.new(
          company_name: registration.company_name,
          email: registration.email,
          name: registration.name,
          registration_id: registration.id
        ).call
      }.to change(Company, :count).by(1)
    end

    it "creates a user" do
      registration = create(:registration)
      expect(Stripe::CreateCustomerJob).to receive(:perform_later)
      expect {
        CreateNewCompany.new(
          company_name: registration.company_name,
          email: registration.email,
          name: registration.name,
          registration_id: registration.id
        ).call
      }.to change(User, :count).by(1)
    end

    it "associates the user with the company" do
      registration = create(:registration)
      expect(Stripe::CreateCustomerJob).to receive(:perform_later)
      CreateNewCompany.new(
        company_name: registration.company_name,
        email: registration.email,
        name: registration.name,
        registration_id: registration.id
      ).call
      user = registration.reload.user
      expect(user.companies.length).to eq(1)
      expect(user.companies.first.name).to match(registration.company_name)
    end

    it "sets the user's name and email from the registration" do
      registration = create(:registration)
      expect(Stripe::CreateCustomerJob).to receive(:perform_later)
      CreateNewCompany.new(
        company_name: registration.company_name,
        email: registration.email,
        name: registration.name,
        registration_id: registration.id
      ).call
      expect(registration.reload.user.name).to eq(registration.name)
      expect(registration.user.email).to eq(registration.email)
    end

    it "sets the user's role to owner" do
      registration = create(:registration)
      expect(Stripe::CreateCustomerJob).to receive(:perform_later)
      CreateNewCompany.new(
        company_name: registration.company_name,
        email: registration.email,
        name: registration.name,
        registration_id: registration.id
      ).call
      expect(registration.reload.user.memberships.first.role).to eq("owner")
    end

    it "sets the user's status to active" do
      registration = create(:registration)
      expect(Stripe::CreateCustomerJob).to receive(:perform_later)
      CreateNewCompany.new(
        company_name: registration.company_name,
        email: registration.email,
        name: registration.name,
        registration_id: registration.id
      ).call
      expect(registration.reload.user.memberships.first.status).to eq("active")
    end

    it "sets the registration's registered_at timestamp" do
      registration = create(:registration)
      expect(Stripe::CreateCustomerJob).to receive(:perform_later)
      CreateNewCompany.new(
        company_name: registration.company_name,
        email: registration.email,
        name: registration.name,
        registration_id: registration.id
      ).call
      expect(registration.reload.registered_at).to be_present
    end

    it "creates a subscription" do
      registration = create(:registration)
      expect(Stripe::CreateCustomerJob).to receive(:perform_later)
      CreateNewCompany.new(
        company_name: registration.company_name,
        email: registration.email,
        name: registration.name,
        registration_id: registration.id
      ).call
      company = registration.reload.user.companies.first
      expect(company.subscription).to be_present
    end

    it "enqueues a job to create a stripe customer" do
      registration = create(:registration)
      expect(Stripe::CreateCustomerJob).to receive(:perform_later)

      command = CreateNewCompany.new(
        company_name: registration.company_name,
        email: registration.email,
        name: registration.name,
        registration_id: registration.id
      )
      command.call
    end
  end
end
