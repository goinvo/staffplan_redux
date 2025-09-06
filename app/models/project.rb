# frozen_string_literal: true

class Project < ApplicationRecord
  belongs_to :client
  has_one :company, through: :client
  has_many :assignments, dependent: :destroy
  has_many :users, through: :assignments
  has_many :work_weeks, through: :assignments, dependent: :destroy

  has_paper_trail

  scope :active, -> { where(status: 'active') }

  UNCONFIRMED = 'unconfirmed'
  CONFIRMED = 'confirmed'
  ARCHIVED = 'archived'
  CANCELLED = 'cancelled'
  COMPLETED = 'completed'
  WEEKLY = 'weekly'
  MONTHLY = 'monthly'
  FORTNIGHTLY = 'fortnightly'
  QUARTERLY = 'quarterly'
  ANNUALLY = 'annually'
  FIXED = 'fixed'
  HOURLY = 'hourly'

  VALID_STATUSES = [UNCONFIRMED, CONFIRMED, ARCHIVED, CANCELLED, COMPLETED].freeze
  VALID_RATE_TYPES = [FIXED, HOURLY].freeze
  VALID_PAYMENT_FREQUENCIES = [WEEKLY, MONTHLY, FORTNIGHTLY, QUARTERLY, ANNUALLY].freeze

  validates :client_id, presence: true # rubocop:disable Rails/RedundantPresneceValidationOnBelongsTo
  validates :name, presence: true, uniqueness: { scope: :client_id, case_sensitive: false }
  validates :status, inclusion: { in: VALID_STATUSES }, allow_blank: true
  validates :cost, numericality: { greater_than_or_equal_to: 0.0 }, allow_blank: true
  validates :payment_frequency, inclusion: { in: VALID_PAYMENT_FREQUENCIES }, allow_blank: true
  validates :fte, numericality: { greater_than_or_equal_to: 0.0 }, allow_blank: true
  validates :rate_type, inclusion: { in: VALID_RATE_TYPES }, allow_blank: true
  validates :hours, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true

  before_destroy :ensure_project_is_destroyable, prepend: true

  def archived?
    status == ARCHIVED
  end

  def can_be_deleted?
    assignments.empty? ||
      WorkWeek.where(assignment: assignments).where.not(actual_hours: 0).empty?
  end

  def cancelled?
    status == CANCELLED
  end

  def completed?
    status == COMPLETED
  end

  def confirmed?
    status == CONFIRMED
  end

  def unconfirmed?
    status == UNCONFIRMED
  end

  private

  # a project is destroyable if it has no assignments OR if its assignments have no actual hours recorded
  def ensure_project_is_destroyable
    return if can_be_deleted?

    errors.add(:base, 'Cannot delete a project that has assignments with hours recorded. Try archiving the project instead.')
    false
  end
end
