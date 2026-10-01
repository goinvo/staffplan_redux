# frozen_string_literal: true

require 'test_helper'

class AddUserToCompanyTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  test 'is invalid without a name' do
    command = AddUserToCompany.new(email: Faker::Internet.email, name: nil, company: create(:company))

    assert_raises(ActiveRecord::RecordInvalid) { command.call }
    assert_equal 1, command.user.errors.count
    assert_equal ["can't be blank"], command.user.errors[:name]
  end

  test 'is invalid without an email' do
    command = AddUserToCompany.new(email: nil, name: Faker::Name.name, company: create(:company))

    assert_raises(ActiveRecord::RecordInvalid) { command.call }
    assert_equal 2, command.user.errors.count
    assert_equal ["can't be blank", 'is invalid'], command.user.errors[:email]
  end

  test 'is invalid without a role' do
    command = AddUserToCompany.new(email: Faker::Internet.email, name: Faker::Name.name, role: nil, company: create(:company))

    assert_raises(ActiveRecord::RecordInvalid) { command.call }
    assert_equal 2, command.membership.errors.count
    assert_equal ["can't be blank", 'is not included in the list'], command.membership.errors[:role]
  end

  test 'is invalid without a company' do
    command = AddUserToCompany.new(email: Faker::Internet.email, name: Faker::Name.name, company: nil)

    assert_raises(ActiveRecord::RecordInvalid) { command.call }
    assert_equal 1, command.user.errors.count
    assert_equal ['must exist'], command.user.errors[:current_company]
  end

  test 'sends a welcome email from the new company' do
    company = create(:membership).company

    assert_enqueued_email_with CompanyMailer, :welcome, args: ->(args) { args.first == company } do
      AddUserToCompany.new(email: Faker::Internet.email, name: Faker::Name.name, company:).call
    end
  end

  test "updates the company's Stripe subscription count" do
    company = create(:membership).company

    assert_enqueued_with(job: Stripe::SyncCustomerSubscriptionJob, args: [company]) do
      AddUserToCompany.new(email: Faker::Internet.email, name: Faker::Name.name, company:).call
    end
  end

  test 'adds an existing user to the company' do
    company = create(:membership).company
    user = create(:user)

    assert_not_includes company.users, user

    assert_enqueued_with(job: Stripe::SyncCustomerSubscriptionJob, args: [company]) do
      AddUserToCompany.new(email: user.email, name: user.name, company:).call
    end

    assert_includes company.users.reload, user
  end

  test 'does not create a new user for an existing email' do
    company = create(:membership).company
    user = create(:user)

    assert_no_difference -> { User.count } do
      AddUserToCompany.new(email: user.email, name: user.name, company:).call
    end
  end

  test 'creates a new user for a new email' do
    company = create(:membership).company
    email = Faker::Internet.email

    assert_nil User.find_by(email:)

    assert_difference -> { User.count }, 1 do
      AddUserToCompany.new(email:, name: Faker::Name.name, company:).call
    end

    assert_not_nil User.find_by(email:)
  end

  test 'adds a new user to the company' do
    company = create(:membership).company

    user = AddUserToCompany.new(email: Faker::Internet.email, name: Faker::Name.name, company:).call

    assert_includes company.users, user
  end

  test 'does not change the current company of existing users' do
    company = create(:membership).company
    user = create(:user)
    current_company = user.current_company

    assert_equal user.companies.first, current_company

    AddUserToCompany.new(email: user.email, name: user.name, company:).call

    assert_equal 2, user.companies.count
    assert_equal current_company, user.reload.current_company
  end

  test "sets the company as a new user's current company" do
    company = create(:membership).company

    user = AddUserToCompany.new(email: Faker::Internet.email, name: Faker::Name.name, company:).call

    assert_equal company, user.current_company
  end
end
