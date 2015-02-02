class CreateStaffplanListWorkWeeks < ActiveRecord::Migration
  def up
    execute %{
      CREATE OR REPLACE VIEW staffplan_list_work_weeks AS
        SELECT
          users.id as user_id,
          MAX(work_weeks.cweek) as cweek,
          MAX(work_weeks.year) as year,
          COALESCE(
            SUM(work_weeks.estimated_hours), 0
          ) as estimated_total,
          COALESCE(
            SUM(work_weeks.actual_hours), 0
          ) as actual_total,
          COALESCE(
            SUM(work_weeks.estimated_hours), 0
          ) as estimated_proposed,
          COALESCE(
            SUM(work_weeks.estimated_hours), 0
          ) as estimated_planned,
          MAX(work_weeks.beginning_of_week) as beginning_of_week
        FROM work_weeks
        JOIN assignments on assignments.id = work_weeks.assignment_id
        JOIN users on assignments.user_id = users.id
        GROUP BY work_weeks.beginning_of_week, assignments.id, users.id
        ORDER BY users.id;
    }
  end

  def down
    execute "DROP VIEW staffplan_list_work_weeks;"
  end
end
