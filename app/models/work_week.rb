class WorkWeek < ApplicationRecord
  belongs_to :assignment
  has_one :user, through: :assignment
  has_one :project, through: :assignment
  has_one :company, through: :project

  has_paper_trail

  validates :assignment_id, presence: true, uniqueness: { scope: [:cweek, :year] }
  validates :cweek, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 53 }
  validates :year, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 2000, less_than_or_equal_to: 2200 }
  validates :estimated_hours, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 168 }
  validates :actual_hours, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 168 }
  validate :no_future_actual_hours

  def is_future_work_week?
    Date.today.year < year || (
      year == Date.today.year && cweek > Date.today.cweek
    )
  end

  private

  def no_future_actual_hours
    return if actual_hours_allowed?

    assign_attributes(actual_hours: 0) if actual_hours > 0
  end

  def year_zero?
    year.blank? || year == 0
  end

  def cweek_zero?
    cweek.blank? || cweek == 0
  end

  def actual_hours_allowed?
    return false if year_zero? || cweek_zero?

    today = Date.today
    today.year > year || (today.year == year && today.cweek >= cweek)
  end
end
