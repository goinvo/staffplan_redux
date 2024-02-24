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
end
