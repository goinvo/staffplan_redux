class Project < ApplicationRecord
  belongs_to :client
  has_one :company, through: :client
  has_many :assignments, dependent: :destroy
  has_many :users, through: :assignments
  has_many :work_weeks, through: :assignments, dependent: :destroy

  has_paper_trail

  scope :active, -> { where(status: 'active') }

  PROPOSED = "proposed".freeze
  ACTIVE = "active".freeze
  ARCHIVED = "archived".freeze
  CANCELLED = "cancelled".freeze
  COMPLETED = "completed".freeze
  WEEKLY = "weekly".freeze
  MONTHLY = "monthly".freeze
  FORTNIGHTLY = "fortnightly".freeze
  QUARTERLY = "quarterly".freeze
  ANNUALLY = "annually".freeze

  VALID_STATUSES = [PROPOSED, ACTIVE, ARCHIVED, CANCELLED, COMPLETED].freeze
  VALID_PAYMENT_FREQUENCIES = [WEEKLY, MONTHLY, FORTNIGHTLY, QUARTERLY, ANNUALLY].freeze

  validates :client_id, presence: true
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }
  validates :cost, presence: true, numericality: { greater_than_or_equal_to: 0.0 }
  validates :payment_frequency, presence: true, inclusion: { in: VALID_PAYMENT_FREQUENCIES }

  def active?
    status == ACTIVE
  end

  def archived?
    status == ARCHIVED
  end

  def proposed?
    status == PROPOSED
  end

  def cancelled?
    status == CANCELLED
  end

  def completed?
    status == COMPLETED
  end
end
