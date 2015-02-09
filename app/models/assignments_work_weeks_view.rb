class AssignmentsWorkWeeksView < ActiveRecord::Base
  self.table_name = "assignments_work_weeks_view"

  scope :active, -> { where(assignment_archived: false) }
  scope :archived, -> { where(assignment_archived: true) }
end
