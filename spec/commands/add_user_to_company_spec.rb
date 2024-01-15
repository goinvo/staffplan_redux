require 'rails_helper'

RSpec.describe "AddUserToCompany" do
  context "when given an existing user's email address" do
    it "adds the user to the company" do
      company = create(:company)
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
      company = create(:company)
      user = create(:user)

      expect do
        AddUserToCompany.new(
          email: user.email,
          name: user.name,
          company: company
        ).call
      end.to change { User.count }.by(0)
    end

    pending "sends a welcome email from the new company"
  end

  context "when given an new user email address" do
    it "creates a new user" do
      company = create(:company)
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
      company = create(:company)

      user = AddUserToCompany.new(
        email: Faker::Internet.email,
        name: Faker::Name.name,
        company: company
      ).call

      expect(company.users).to include user
    end

    it "sets the company as the user's current company" do
      company = create(:company)
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