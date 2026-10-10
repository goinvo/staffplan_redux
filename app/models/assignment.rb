# frozen_string_literal: true

class Assignment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :project
  has_one :company, through: :user, source: :current_company
  has_many :work_weeks, dependent: :destroy

  has_paper_trail

  PROPOSED = 'proposed'
  ACTIVE = 'active'
  ARCHIVED = 'archived'
  COMPLETED = 'completed'
  VALID_STATUSES = [PROPOSED, ACTIVE, ARCHIVED, COMPLETED].freeze

  validates :user_id, presence: true, uniqueness: { scope: :project_id }, if: ->(assignment) { assignment.status != PROPOSED }
  validates :project_id, presence: true, uniqueness: { scope: :user_id, allow_nil: true }, if: ->(assignment) { assignment.user_id.present? }
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }
  validate :starts_and_ends_on_rules
  validate :project_and_user_belong_to_same_company
  before_destroy :cannot_delete_assigned_assignments_with_actual_hours_recorded, prepend: true

  scope :for_user, ->(user) { where(user: user) }

  def fill_forward(from:, through:, estimated_hours:)
    through = [through, ends_on].compact.min

    transaction do
      (from..through).step(7).map { upsert_work_week(cweek: it.cweek, year: it.cwyear, estimated_hours:) }
    end
  end

  def upsert_work_week(cweek:, year:, estimated_hours: nil, actual_hours: nil)
    work_week = work_weeks.find_or_initialize_by(cweek:, year:)

    if work_week_locked?(work_week)
      work_week.errors.add(:base, :locked, message: 'Unable to edit future work weeks for inactive users')
    elsif work_week.is_future_work_week? && estimated_hours.to_i.zero?
      work_week.destroy
    else
      work_week.update({ estimated_hours:, actual_hours: }.compact)
    end

    work_week
  end

  private

  def cannot_delete_assigned_assignments_with_actual_hours_recorded
    return if user_id.blank? || user.blank?

    if work_weeks.any? { |ww| ww.actual_hours.positive? }
      errors.add(:base, "Cannot delete an assignment that's assigned with hours recorded. Try archiving the assignment instead.")

      throw :abort
    end
  end

  def project_and_user_belong_to_same_company
    # other validations will catch this, so we can return early
    return if project.blank? || user.blank?

    project_company_users = project.company.active_users
    return if project_company_users.include?(user)

    errors.add(:project, 'and user must belong to the same company')
  end

  def starts_and_ends_on_rules
    return if starts_on.blank? || ends_on.blank?

    if starts_on > ends_on
      errors.add(:starts_on, "can't be after the assignment ends")
      errors.add(:ends_on, "can't come before the assignment starts")
    end
  end

  def work_week_locked?(work_week)
    return false if user.blank?

    membership = user.memberships.find_by(company: project.company)
    membership&.inactive? && work_week.is_future_work_week?(relative_to_date: membership.updated_at.to_date)
  end
end
