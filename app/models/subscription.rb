# frozen_string_literal: true

class Subscription < ApplicationRecord
  INCOMPLETE = 'incomplete'
  INCOMPLETE_EXPIRED = 'incomplete_expired'
  TRIALING = 'trialing'
  ACTIVE = 'active'
  PAST_DUE = 'past_due'
  CANCELED = 'canceled'
  UNPAID = 'unpaid'

  CARD = 'card'
  LINK = 'link'

  belongs_to :company

  validates :payment_method_type, inclusion: { in: [CARD, LINK] }, if: -> { default_payment_method.present? }
  validates :status, inclusion: { in: [INCOMPLETE, INCOMPLETE_EXPIRED, TRIALING, ACTIVE, PAST_DUE, CANCELED, UNPAID] }

  def active?
    status == ACTIVE
  end

  def can_be_resumed?
    canceled? && current_period_end > Time.now.utc
  end

  def canceled?
    status == CANCELED || canceled_at.present?
  end

  def card_payment_method?
    payment_method_type == CARD
  end

  def credit_card_brand
    return if default_payment_method.blank?

    payment_metadata['credit_card_brand']
  end

  def credit_card_exp_month
    return if default_payment_method.blank?

    payment_metadata['credit_card_exp_month']
  end

  def credit_card_exp_year
    return if default_payment_method.blank?

    payment_metadata['credit_card_exp_year']
  end

  def credit_card_last_four
    return if default_payment_method.blank?

    payment_metadata['credit_card_last_four']
  end

  def link_email
    return if default_payment_method.blank?

    payment_metadata['email']
  end

  def link_payment_method?
    payment_method_type == LINK
  end

  def trialing?
    status == TRIALING && default_payment_method.blank?
  end

  def trialing_with_payment_method?
    status == TRIALING && default_payment_method.present?
  end
end
