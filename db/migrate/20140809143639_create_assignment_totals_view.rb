class CreateAssignmentTotalsView < ActiveRecord::Migration
  def up
    execute %{
      CREATE OR REPLACE VIEW assignment_totals_view AS
        SELECT
          assignments.id AS assignment_id,
          SUM(work_weeks.estimated_hours) AS estimated_total,
          SUM(work_weeks.actual_hours) AS actual_total,
          (SUM(work_weeks.actual_hours) - SUM(work_weeks.estimated_hours)) AS diff
        FROM assignments
        INNER JOIN work_weeks ON work_weeks.assignment_id = assignments.id
        GROUP BY assignments.id, work_weeks.assignment_id
    }
  end
  
  def down
    execute "DROP VIEW assignment_totals_view;"
  end
end
