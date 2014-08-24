class CreateStaffplanListView < ActiveRecord::Migration
  def up
    execute %{
      CREATE OR REPLACE VIEW staffplan_list_view AS
        SELECT
          users.id AS user_id,
          assignments.id AS assignment_id,
          work_weeks.beginning_of_week AS beginning_of_week,
          SUM(work_weeks.estimated_hours) AS estimated_total,
          SUM(work_weeks.actual_hours) AS actual_total,
          (SUM(work_weeks.actual_hours) - SUM(work_weeks.estimated_hours)) AS diff
        FROM users
        INNER JOIN assignments ON assignments.user_id = users.id
        INNER JOIN work_weeks ON work_weeks.assignment_id = assignments.id
        GROUP BY users.id, assignments.id, work_weeks.beginning_of_week
    }
  end
  
  def down
    execute "DROP VIEW staffplan_list_view;"
  end
end
