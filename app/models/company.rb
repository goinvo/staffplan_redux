# frozen_string_literal: true

class Company < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :clients, dependent: :destroy
  has_many :projects, through: :clients
  has_many :work_weeks, through: :projects
  has_many :assignments, through: :projects
  has_one :subscription

  has_paper_trail

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end

  validates :name, presence: true

  before_create :build_default_subscription

  def active_users
    users.joins(:memberships).where(memberships: { status: Membership::ACTIVE })
  end

  def admin_or_owner?(user:)
    user.owner?(company: self) || user.admin?(company: self)
  end

  def build_default_subscription
    # these values will be overwritten by the webhook, but set them here so the page
    # can render before the webhook is received
    build_subscription(status: 'trialing', trial_end: 30.days.from_now)
  end

  def can_access?(user:)
    membership = memberships.find_by(user: user)
    membership.present? && membership.active?
  end

  def owners
    memberships.owners.map(&:user)
  end

  def restore_avatar
    if avatar.attached? && avatar.changed?
      original_picture = avatar.attachment_was
      if original_picture
        # Detach the current attachment
        avatar.detach

        # Reattach the original attachment
        avatar.attach(original_picture)
      end
    end
  end
end
