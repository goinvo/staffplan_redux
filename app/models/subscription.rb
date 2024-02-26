class Subscription < ApplicationRecord

  INCOMPLETE = "incomplete".freeze
  INCOMPLETE_EXPIRED = "incomplete_expired".freeze
  TRIALING = "trialing".freeze
  ACTIVE = "active".freeze
  PAST_DUE = "past_due".freeze
  CANCELED = "canceled".freeze
  UNPAID = "unpaid".freeze

  belongs_to :company

  validates :status, presence: true, inclusion: { in: [INCOMPLETE, INCOMPLETE_EXPIRED, TRIALING, ACTIVE, PAST_DUE, CANCELED, UNPAID] }

  def active?
    status == ACTIVE
  end

  def canceled?
    status == CANCELED || canceled_at.present?
  end

  def trialing?
    status == TRIALING && default_payment_method.blank?
  end

  def trialing_with_payment_method?
    status == TRIALING && default_payment_method.present?
  end

  def can_be_resumed?
    canceled? && current_period_end > Time.now.utc
  end
end
