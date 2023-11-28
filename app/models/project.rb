class Project < ApplicationRecord
  belongs_to :client
  has_one :company, through: :client
  has_many :assignments, dependent: :destroy
  has_many :users, through: :assignments
  has_many :work_weeks, through: :assignments, dependent: :destroy

  scope :active, -> { where(status: 'active') }

  VALID_STATUSES = %w(proposed active archived cancelled completed).freeze
  VALID_PAYMENT_FREQUENCIES = %w(weekly monthly fortnightly quarterly annually).freeze

  validates :client_id, presence: true
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }
  validates :cost, presence: true, numericality: { greater_than_or_equal_to: 0.0 }
  validates :payment_frequency, presence: true, inclusion: { in: VALID_PAYMENT_FREQUENCIES }
end
