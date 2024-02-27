class Subscription < ApplicationRecord

  INCOMPLETE = "incomplete".freeze
  INCOMPLETE_EXPIRED = "incomplete_expired".freeze
  TRIALING = "trialing".freeze
  ACTIVE = "active".freeze
  PAST_DUE = "past_due".freeze
  CANCELED = "canceled".freeze
  UNPAID = "unpaid".freeze

  CARD = "card".freeze
  LINK = "link".freeze

  belongs_to :company

  validates :payment_method_type, inclusion: { in: [CARD, LINK] }, if: -> { default_payment_method.present? }
  validates :status, inclusion: { in: [INCOMPLETE, INCOMPLETE_EXPIRED, TRIALING, ACTIVE, PAST_DUE, CANCELED, UNPAID] }

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

  def credit_card_brand
    return if default_payment_method.blank?
    payment_metadata["credit_card_brand"]
  end

  def credit_card_last_four
    return if default_payment_method.blank?
    payment_metadata["credit_card_last_four"]
  end

  def credit_card_exp_month
    return if default_payment_method.blank?
    payment_metadata["credit_card_exp_month"]
  end

  def credit_card_exp_year
    return if default_payment_method.blank?
    payment_metadata["credit_card_exp_year"]
  end

  def link_email
    return if default_payment_method.blank?
    payment_metadata["email"]
  end

  def card_payment_method?
    payment_method_type == CARD
  end

  def link_payment_method?
    payment_method_type == LINK
  end
end
