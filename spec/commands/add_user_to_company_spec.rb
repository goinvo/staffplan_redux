require 'rails_helper'

RSpec.describe "AddUserToCompany" do
  context "validations" do
    it "is invalid without a name" do
      company = create(:company)

      command = AddUserToCompany.new(
        email: Faker::Internet.email,
        name: nil,
        company: company
      )

      expect { command.call }.to raise_error(ActiveRecord::RecordInvalid)

      user = command.user
      expect(user.errors.count).to eq(1)
      expect(user.errors[:name]).to eq(["can't be blank"])
    end

    it "is invalid without an email" do
      company = create(:company)

      command = AddUserToCompany.new(
        email: nil,
        name: Faker::Name.name,
        company: company
      )

      expect { command.call }.to raise_error(ActiveRecord::RecordInvalid)
      user = command.user

      expect(user.errors.count).to eq(2)
      expect(user.errors[:email]).to eq(["can't be blank", "is invalid"])
    end

    it "is invalid without a role" do
      company = create(:company)

      command = AddUserToCompany.new(
        email: Faker::Internet.email,
        name: Faker::Name.name,
        role: nil,
        company: company
      )

      expect { command.call }.to raise_error(ActiveRecord::RecordInvalid)
      membership = command.membership

      expect(membership.errors.count).to eq(2)
      expect(membership.errors[:role]).to eq(["can't be blank", "is not included in the list"])
    end

    it "is invalid without a company" do
      command = AddUserToCompany.new(
        email: Faker::Internet.email,
        name: Faker::Name.name,
        company: nil
      )

      expect { command.call }.to raise_error(ActiveRecord::RecordInvalid)
      user = command.user

      expect(user.errors.count).to eq(2)
      expect(user.errors[:current_company]).to eq(["must exist", "can't be blank"])
    end
  end

  context "for all users" do
    it "sends a welcome email from the new company" do
      company = create(:membership).company
      expect(SyncCustomerSubscriptionJob).to receive(:perform_async).with(company.id)

      AddUserToCompany.new(
        email: user_email = Faker::Internet.email,
        name: Faker::Name.name,
        company: company
      ).call
    end

    it "updates the company's Stripe subscription count" do
      company = create(:membership).company
      expect(SyncCustomerSubscriptionJob).to receive(:perform_async).with(company.id)

      AddUserToCompany.new(
        email: Faker::Internet.email,
        name: Faker::Name.name,
        company: company
      ).call
    end
  end

  context "when given an existing user's email address" do
    it "adds the user to the company" do
      company = create(:membership).company
      expect(SyncCustomerSubscriptionJob).to receive(:perform_async).with(company.id)

      user = create(:user)

      expect(company.users).to_not include user

      AddUserToCompany.new(
        email: user.email,
        name: user.name,
        company: company
      ).call

      expect(company.users.reload).to include user
    end

    it "does not create a new user" do
      company = create(:membership).company
      expect(SyncCustomerSubscriptionJob).to receive(:perform_async).with(company.id)
      user = create(:user)

      expect do
        AddUserToCompany.new(
          email: user.email,
          name: user.name,
          company: company
        ).call
      end.to change { User.count }.by(0)
    end
  end

  context "when given an new user email address" do
    it "creates a new user" do
      company = create(:membership).company
      expect(SyncCustomerSubscriptionJob).to receive(:perform_async).with(company.id)

      email = Faker::Internet.email

      expect(User.find_by(email:)).to be_nil

      expect do
        AddUserToCompany.new(
          email:,
          name: Faker::Name.name,
          company: company
        ).call
      end.to change { User.count }.by(1)

      expect(User.find_by(email:)).to_not be_nil
    end

    it "adds the user to the company" do
      company = create(:membership).company
      expect(SyncCustomerSubscriptionJob).to receive(:perform_async).with(company.id)

      user = AddUserToCompany.new(
        email: Faker::Internet.email,
        name: Faker::Name.name,
        company: company
      ).call

      expect(company.users).to include user
    end

    it "does not set the current_company for existing users" do
      company = create(:membership).company
      expect(SyncCustomerSubscriptionJob).to receive(:perform_async).with(company.id)

      user = create(:user)
      current_company = user.current_company
      expect(current_company).to eq(user.companies.first)

      AddUserToCompany.new(
        email: user.email,
        name: user.name,
        company: company
      ).call

      expect(user.companies.count).to eq(2)
      expect(user.reload.current_company).to eq(current_company)
    end

    it "sets the company as the user's current company for new users" do
      company = create(:membership).company
      expect(SyncCustomerSubscriptionJob).to receive(:perform_async).with(company.id)

      email = Faker::Internet.email

      user = AddUserToCompany.new(
        email:,
        name: Faker::Name.name,
        company: company
      ).call

      expect(user.current_company).to eq company
    end
  end
end