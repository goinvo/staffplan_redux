class AssignmentWorkWeekSerializer < ActiveModel::Serializer
  attributes :assignment_id, :is_proposed, :is_archived, :work_week_id, :estimated, :actual, :cweek, :year, :beginning_of_week

  def actual
    object.actual_hours
  end

  def estimated
    object.estimated_hours
  end
end
