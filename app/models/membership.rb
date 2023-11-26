class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :company

  validates :user, presence: true, uniqueness: { scope: :company }
  validates :company, presence: true, uniqueness: { scope: :user }
  validates :status, presence: true, inclusion: { in: %w[active inactive] }
  validates :role, presence: true, inclusion: { in: %w[owner admin member] }
end
