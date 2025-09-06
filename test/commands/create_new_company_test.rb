# frozen_string_literal: true

require 'test_helper'

class CreateNewCompanyTest < ActiveSupport::TestCase
  describe '#call' do
    it 'creates a company' do
      registration = create(:registration)
      job_called = false
      Stripe::CreateCustomerJob.stub :perform_later, ->(_company) { job_called = true } do
        assert_difference('Company.count', 1) do
          CreateNewCompany.new(
            company_name: registration.company_name,
            email: registration.email,
            name: registration.name,
            registration_id: registration.id,
          ).call
        end
        assert job_called
      end
    end

    it 'creates a user' do
      registration = create(:registration)
      job_called = false
      Stripe::CreateCustomerJob.stub :perform_later, ->(_company) { job_called = true } do
        assert_difference('User.count', 1) do
          CreateNewCompany.new(
            company_name: registration.company_name,
            email: registration.email,
            name: registration.name,
            registration_id: registration.id,
          ).call
        end
        assert job_called
      end
    end

    it 'associates the user with the company' do
      registration = create(:registration)
      job_called = false
      Stripe::CreateCustomerJob.stub :perform_later, ->(_company) { job_called = true } do
        CreateNewCompany.new(
          company_name: registration.company_name,
          email: registration.email,
          name: registration.name,
          registration_id: registration.id,
        ).call
        user = registration.reload.user

        assert_equal 1, user.companies.length
        assert_match registration.company_name, user.companies.first.name
        assert job_called
      end
    end

    it "sets the user's name and email from the registration" do
      registration = create(:registration)
      job_called = false
      Stripe::CreateCustomerJob.stub :perform_later, ->(_company) { job_called = true } do
        CreateNewCompany.new(
          company_name: registration.company_name,
          email: registration.email,
          name: registration.name,
          registration_id: registration.id,
        ).call

        assert_equal registration.name, registration.reload.user.name
        assert_equal registration.email, registration.user.email
        assert job_called
      end
    end

    it "sets the user's role to owner" do
      registration = create(:registration)
      job_called = false
      Stripe::CreateCustomerJob.stub :perform_later, ->(_company) { job_called = true } do
        CreateNewCompany.new(
          company_name: registration.company_name,
          email: registration.email,
          name: registration.name,
          registration_id: registration.id,
        ).call

        assert_equal 'owner', registration.reload.user.memberships.first.role
        assert job_called
      end
    end

    it "sets the user's status to active" do
      registration = create(:registration)
      job_called = false
      Stripe::CreateCustomerJob.stub :perform_later, ->(_company) { job_called = true } do
        CreateNewCompany.new(
          company_name: registration.company_name,
          email: registration.email,
          name: registration.name,
          registration_id: registration.id,
        ).call

        assert_equal 'active', registration.reload.user.memberships.first.status
        assert job_called
      end
    end

    it "sets the registration's registered_at timestamp" do
      registration = create(:registration)
      job_called = false
      Stripe::CreateCustomerJob.stub :perform_later, ->(_company) { job_called = true } do
        CreateNewCompany.new(
          company_name: registration.company_name,
          email: registration.email,
          name: registration.name,
          registration_id: registration.id,
        ).call

        assert_predicate registration.reload.registered_at, :present?
        assert job_called
      end
    end

    it 'creates a subscription' do
      registration = create(:registration)
      job_called = false
      Stripe::CreateCustomerJob.stub :perform_later, ->(_company) { job_called = true } do
        CreateNewCompany.new(
          company_name: registration.company_name,
          email: registration.email,
          name: registration.name,
          registration_id: registration.id,
        ).call
        company = registration.reload.user.companies.first

        assert_predicate company.subscription, :present?
        assert job_called
      end
    end

    it 'enqueues a job to create a stripe customer' do
      registration = create(:registration)
      job_called = false
      Stripe::CreateCustomerJob.stub :perform_later, ->(_company) { job_called = true } do
        command = CreateNewCompany.new(
          company_name: registration.company_name,
          email: registration.email,
          name: registration.name,
          registration_id: registration.id,
        )
        command.call

        assert job_called
      end
    end
  end
end
