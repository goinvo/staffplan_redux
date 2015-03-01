class UserProjectsViewSerializer < ActiveModel::Serializer

  attributes :project_id, :user_id, :company_id, :assignment_id, :assignment_proposed, :assignment_archived,
             :client_id, :client_name, :project_name, :project_active, :work_weeks,
             :estimated_total, :actual_total, :diff

  def estimated_total
    object.assignment_totals.estimated_total rescue 0
  end

  def actual_total
    object.assignment_totals.actual_total rescue 0
  end

  def diff
    object.assignment_totals.diff rescue 0
  end

  def work_weeks
    # :assignment_id, :user_id, :assignment_proposed, :assignment_archived, :work_week_id,
    # :estimated_hours, :actual_hours, :cweek, :year, :beginning_of_week
    object.work_weeks.map do |work_week|
      work_week.attributes.merge(
        estimated_proposed: (object.assignment_proposed? ? work_week.estimated_hours : 0),
        estimated_planned: (object.assignment_proposed? ? 0 : work_week.estimated_hours)
      )
    end
  end
end
