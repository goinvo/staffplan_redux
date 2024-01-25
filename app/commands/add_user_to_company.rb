# frozen_string_literal: true

class AddUserToCompany

  attr_accessor :user, :membership
  attr_reader :errors

  class InvalidArguments < StandardError; end

  def initialize(email:, name:, role: "member", company:)
    @email = email
    @name = name
    @role = role
    @company = company
  end

  def call
    User.transaction do
      find_or_create_user
      add_user_to_company
      send_welcome_email
      update_stripe_subscription_count
    end

    @user
  end

  private

  def find_or_create_user
    @user = User.find_or_initialize_by(email: @email) do |user|
      user.name = @name
      user.current_company = @company
    end

    @user.save!
  end

  def add_user_to_company
    @membership = @company.memberships.build(user: @user, role: @role, status: 'active')
    @membership.save!
  end

  def send_welcome_email

  end

  def update_stripe_subscription_count

  end
end