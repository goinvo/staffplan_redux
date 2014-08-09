class CreateAssignmentWorkWeeksView < ActiveRecord::Migration
  def up
    execute %{
      CREATE OR REPLACE VIEW assignment_work_weeks_view AS
        SELECT
          assignments.id AS assignment_id,
          assignments.proposed AS is_proposed,
          assignments.archived AS is_archived,
          work_weeks.id AS work_week_id,
          work_weeks.estimated_hours AS estimated_hours,
          work_weeks.actual_hours AS actual_hours,
          work_weeks.cweek AS cweek,
          work_weeks.year AS year,
          work_weeks.beginning_of_week AS beginning_of_week
        FROM assignments
        INNER JOIN work_weeks ON work_weeks.assignment_id = assignments.id
    }
  end
  
  def down
    execute "DROP VIEW assignment_work_weeks_view;"
  end
end
