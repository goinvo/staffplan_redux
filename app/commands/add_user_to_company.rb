# frozen_string_literal: true

class AddUserToCompany
  attr_accessor :user, :membership
  attr_reader :errors

  class InvalidArguments < StandardError; end

  def initialize(email:, name:, company:, role: 'member', creating_new_company: false)
    @email = email
    @name = name
    @role = role
    @creating_new_company = creating_new_company
    @company = company
  end

  def call
    User.transaction do
      find_or_create_user
      add_user_to_company

      unless @creating_new_company
        send_welcome_email
        update_stripe_subscription_count
      end
    end

    @user
  end

  private

  def add_user_to_company
    @membership = @company.memberships.build(user: @user, role: @role, status: 'active')
    @membership.save!
  end

  def find_or_create_user
    @user = User.find_or_initialize_by(email: @email) do |user|
      user.name = @name
      user.current_company = @company
    end

    @user.save!
  end

  def send_welcome_email
    CompanyMailer.welcome(@company, @user).deliver_later
  end

  def update_stripe_subscription_count
    Stripe::SyncCustomerSubscriptionJob.perform_later(@company)
  end
end
