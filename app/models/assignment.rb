class Assignment < ApplicationRecord
  belongs_to :user
  belongs_to :project
  has_many :work_weeks, dependent: :destroy

  PROPOSED = "proposed".freeze
  ACTIVE = "active".freeze
  ARCHIVED = "archived".freeze
  COMPLETED = "completed".freeze
  VALID_STATUSES = [PROPOSED, ACTIVE, ARCHIVED, COMPLETED].freeze

  validates :user_id, presence: true, uniqueness: { scope: :project_id }
  validates :project_id, presence: true, uniqueness: { scope: :user_id }
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }

  scope :for_user, ->(user) { where(user: user) }
end
