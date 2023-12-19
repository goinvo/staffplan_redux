class WorkWeek < ApplicationRecord
  belongs_to :assignment
  has_one :user, through: :assignment
  has_one :project, through: :assignment

  validates :assignment_id, presence: true, uniqueness: { scope: :beginning_of_week }
  validates :cweek, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 53 }
  validates :year, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 2000, less_than_or_equal_to: 2200 }
  validates :beginning_of_week, presence: true, numericality: { only_integer: true }
  validates :estimated_hours, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 24 }
  validates :actual_hours, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 24 }

  def turbo_frame_id
    "work_week|a:#{assignment.id}|u:#{assignment.user.id}|bow:#{beginning_of_week}|cweek:#{cweek}|year:#{year}"
  end
end
