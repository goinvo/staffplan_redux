class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :company

  has_paper_trail

  OWNER = 'owner'.freeze
  ADMIN = 'admin'.freeze
  MEMBER = 'member'.freeze
  ACTIVE = 'active'.freeze
  INACTIVE = 'inactive'.freeze

  VALID_ROLES = [OWNER, ADMIN, MEMBER].freeze
  VALID_STATUSES = [ACTIVE, INACTIVE].freeze

  validates :user, presence: true, uniqueness: { scope: :company }
  validates :company, presence: true, uniqueness: { scope: :user }
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }
  validates :role, presence: true, inclusion: { in: VALID_ROLES }

  scope :active, -> { where(status: Membership::ACTIVE) }
  scope :owners, -> { where(role: Membership::OWNER) }

  def active?
    status == Membership::ACTIVE
  end

  def inactive?
    status == Membership::INACTIVE
  end
end
