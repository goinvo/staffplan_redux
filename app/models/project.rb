class Project < ApplicationRecord
  belongs_to :client
  has_one :company, through: :client
  has_many :assignments, dependent: :destroy
  has_many :users, through: :assignments
  has_many :work_weeks, through: :assignments, dependent: :destroy

  has_paper_trail

  scope :active, -> { where(status: 'active') }

  UNCONFIRMED = "unconfirmed".freeze
  CONFIRMED = "confirmed".freeze
  ARCHIVED = "archived".freeze
  CANCELLED = "cancelled".freeze
  COMPLETED = "completed".freeze
  WEEKLY = "weekly".freeze
  MONTHLY = "monthly".freeze
  FORTNIGHTLY = "fortnightly".freeze
  QUARTERLY = "quarterly".freeze
  ANNUALLY = "annually".freeze

  VALID_STATUSES = [UNCONFIRMED, CONFIRMED, ARCHIVED, CANCELLED, COMPLETED].freeze
  VALID_PAYMENT_FREQUENCIES = [WEEKLY, MONTHLY, FORTNIGHTLY, QUARTERLY, ANNUALLY].freeze

  validates :client_id, presence: true
  validates :name, presence: true, uniqueness: { scope: :client_id, case_sensitive: false }
  validates :status, inclusion: { in: VALID_STATUSES }, allow_blank: true
  validates :cost, numericality: { greater_than_or_equal_to: 0.0 }, allow_blank: true
  validates :payment_frequency, inclusion: { in: VALID_PAYMENT_FREQUENCIES }, allow_blank: true
  validates :fte, numericality: { greater_than_or_equal_to: 0.0 }, allow_blank: true
  validates :hours, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true

  def confirmed?
    status == CONFIRMED
  end

  def archived?
    status == ARCHIVED
  end

  def unconfirmed?
    status == UNCONFIRMED
  end

  def cancelled?
    status == CANCELLED
  end

  def completed?
    status == COMPLETED
  end
end
