class Assignment < ApplicationRecord
  belongs_to :user
  belongs_to :project
  has_one :company, through: :user, source: :current_company
  has_many :work_weeks, dependent: :destroy

  has_paper_trail

  PROPOSED = "proposed".freeze
  ACTIVE = "active".freeze
  ARCHIVED = "archived".freeze
  COMPLETED = "completed".freeze
  VALID_STATUSES = [PROPOSED, ACTIVE, ARCHIVED, COMPLETED].freeze

  validates :user_id, presence: true, uniqueness: { scope: :project_id }
  validates :project_id, presence: true, uniqueness: { scope: :user_id }
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }
  validate :starts_and_ends_on_rules
  validate :project_and_user_belong_to_same_company

  scope :for_user, ->(user) { where(user: user) }

  private

  def project_and_user_belong_to_same_company
    # other validations will catch this, so we can return early
    return if project.blank? || user.blank?

    project_company_users = project.company.active_users
    return if project_company_users.include?(user)

    errors.add(:project, "and user must belong to the same company")
  end

  def starts_and_ends_on_rules
    if starts_on.blank? && ends_on.present?
      errors.add(:starts_on, "is required if an end date is set")
    end

    if ends_on.blank? && starts_on.present?
      errors.add(:ends_on, "is required if a start date is set")
    end

    return if starts_on.blank? || ends_on.blank?

    if starts_on > ends_on
      errors.add(:starts_on, "can't be after the assignment ends")
      errors.add(:ends_on, "can't come before the assignment starts")
    end
  end
end
