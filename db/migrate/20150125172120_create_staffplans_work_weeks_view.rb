class CreateStaffplansWorkWeeksView < ActiveRecord::Migration
  def up
    execute %{
      CREATE OR REPLACE VIEW staffplans_work_weeks_view AS
        SELECT
          users.id as user_id,
          assignments.id as assignment_id,
          MAX(ww1.cweek) as cweek,
          MAX(ww1.year) as year,
          COALESCE(
            SUM(ww1.estimated_hours), 0
          ) as estimated_total,
          COALESCE(
            SUM(ww1.actual_hours), 0
          ) as actual_total,
          MAX(ww1.beginning_of_week) as beginning_of_week
        FROM work_weeks AS ww1
        JOIN assignments on assignments.id = ww1.assignment_id
        JOIN users on assignments.user_id = users.id
        GROUP BY ww1.beginning_of_week, assignments.id, users.id
        ORDER BY users.id;
    }
  end

  def down
    execute "DROP VIEW staffplans_work_weeks_view;"
  end
end
