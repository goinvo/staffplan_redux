class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :company

  OWNER = 'owner'.freeze
  ADMIN = 'admin'.freeze
  MEMBER = 'member'.freeze

  VALID_ROLES = [OWNER, ADMIN, MEMBER].freeze
  VALID_STATUSES = %w[active inactive].freeze

  validates :user, presence: true, uniqueness: { scope: :company }
  validates :company, presence: true, uniqueness: { scope: :user }
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }
  validates :role, presence: true, inclusion: { in: VALID_ROLES }
end
