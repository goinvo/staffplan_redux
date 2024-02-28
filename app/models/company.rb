class Company < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :clients, dependent: :destroy
  has_many :projects, through: :clients
  has_many :work_weeks, through: :projects
  has_many :assignments, through: :projects
  has_one :subscription

  has_paper_trail

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_create :build_default_subscription

  def build_default_subscription
    # these values will be overwritten by the webhook, but set them here so the page
    # can render before the webhook is received
    build_subscription(status: "trialing", trial_end: 30.days.from_now)
  end

  def active_users
    users.joins(:memberships).where(memberships: { status: Membership::ACTIVE })
  end

  def owners
    memberships.owners.map(&:user)
  end

  def can_access?(user:)
    membership = memberships.find_by(user: user)
    membership.present? && membership.active?
  end
end
