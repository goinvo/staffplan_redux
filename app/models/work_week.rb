# frozen_string_literal: true

class WorkWeek < ApplicationRecord
  belongs_to :assignment
  has_one :user, through: :assignment
  has_one :project, through: :assignment
  has_one :company, through: :project

  has_paper_trail

  validates :assignment_id, uniqueness: { scope: %i[cweek year] }
  validates :cweek, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 53 }
  validates :year, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 2000, less_than_or_equal_to: 2200 }
  validates :estimated_hours, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 168 }
  validates :actual_hours, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 168 }
  validate :no_future_actual_hours

  before_commit :update_assignment_focused_if_future_work_week, on: %i[create update]

  def day
    Date.commercial(year, cweek, 1).day
  end

  def is_future_work_week?(relative_to_date: Time.zone.today)
    relative_to_date.cwyear < year || (
      year == relative_to_date.cwyear && cweek > relative_to_date.cweek
    )
  end

  def is_current_week?(relative_to_date: Time.zone.today)
    relative_to_date.cwyear == year && relative_to_date.cweek == cweek
  end

  private

  def actual_hours_allowed?
    return false if year_zero? || cweek_zero?

    today = Time.zone.today
    today.cwyear > year || (today.cwyear == year && today.cweek >= cweek)
  end

  def cweek_zero?
    cweek.blank? || cweek.zero?
  end

  def no_future_actual_hours
    return if actual_hours_allowed?

    assign_attributes(actual_hours: 0) if actual_hours.positive?
  end

  def update_assignment_focused_if_future_work_week
    return unless is_future_work_week?

    assignment.update(focused: true)
  end

  def year_zero?
    year.blank? || year.zero?
  end
end
