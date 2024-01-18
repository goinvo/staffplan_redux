class Client < ApplicationRecord
  belongs_to :company
  has_many :projects, dependent: :destroy

  ACTIVE = 'active'.freeze
  ARCHIVED = 'archived'.freeze

  VALID_STATUSES = [ACTIVE, ARCHIVED].freeze

  validates :company_id, presence: true, uniqueness: { scope: :name }
  validates :name, presence: true, uniqueness: { scope: :company_id }
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }

  scope :active, -> { where(status: 'active') }
  scope :archived, -> { where(status: 'archived') }
end
