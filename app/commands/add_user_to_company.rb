# frozen_string_literal: true

class AddUserToCompany

  attr_accessor :user

  def initialize(email:, name:, role: "member", company:)
    @email = email
    @name = name
    @role = role
    @company = company
  end

  def call
    find_or_create_user
    add_user_to_company

    @user
  end

  private

  def find_or_create_user
    @user = User.find_or_initialize_by(email: @email) do |user|
      user.name = @name
      user.current_company = @company
    end
  end

  def add_user_to_company
    @company.memberships.build(user: @user, role: @role, status: 'active')
    @company.save!
  end
end