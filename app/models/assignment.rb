class Assignment < ApplicationRecord
  belongs_to :user
  belongs_to :project
  has_many :work_weeks, dependent: :destroy

  VALID_STATUSES = %w(proposed active archived completed).freeze

  validates :user_id, presence: true, uniqueness: { scope: :project_id }
  validates :project_id, presence: true, uniqueness: { scope: :user_id }
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }
end
