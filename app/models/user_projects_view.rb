class UserProjectsView < ActiveRecord::Base
  self.table_name = "user_projects_view"

  scope :for_user, -> (user) do
    where("user_id = ?", user.id).where(is_archived: false)
  end

  scope :active, -> { where(is_archived: false) }

  has_many :work_weeks, class_name: "AssignmentWorkWeeksView", primary_key: :assignment_id, foreign_key: :assignment_id
  has_one :assignment_totals, class_name: "AssignmentTotal", primary_key: :assignment_id, foreign_key: :assignment_id
end
