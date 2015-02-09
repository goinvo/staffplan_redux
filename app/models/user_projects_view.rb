class UserProjectsView < ActiveRecord::Base
  self.table_name = "user_projects_view"

  scope :for_user, -> (user) do
    where("user_id = ?", user.id).where(assignment_archived: false)
  end

  scope :active, -> { where(assignment_archived: false) }

  has_many :work_weeks, class_name: "AssignmentsWorkWeeksView", primary_key: :assignment_id, foreign_key: :assignment_id
  has_one :assignment_totals, class_name: "AssignmentsTotalsView", primary_key: :assignment_id, foreign_key: :assignment_id
end
