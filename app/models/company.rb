class Company < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :clients, dependent: :destroy
  has_many :projects, through: :clients
  has_many :work_weeks, through: :projects
  has_many :assignments, through: :projects

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def subscription
    @_subscription if defined?(@_subscription)

    @_subscription = Stripe::Subscription.list({ customer: stripe_id }).first
  end

  def owners
    memberships.owners.map(&:user)
  end
end
