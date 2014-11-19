class AssignmentWorkWeekSerializer < ActiveModel::Serializer
  attributes :assignment_id, :user_id, :assignment_proposed, :assignment_archived, :work_week_id, :estimated_hours, :actual_hours, :cweek, :year, :beginning_of_week
end
