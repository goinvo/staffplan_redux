class CreateStaffplansTotalsView < ActiveRecord::Migration
  def up
    execute %{
      CREATE OR REPLACE VIEW staffplans_totals_view AS
        SELECT
          user_id,
          MAX(estimated_total) AS estimated_total,
          MAX(actual_total) AS actual_total,
          MAX(diff) AS diff
        FROM (
          SELECT
            MAX(assignments.user_id) as user_id,
            COALESCE(
              SUM(work_weeks.estimated_hours), 0
            ) as estimated_total,
            COALESCE(
              SUM(work_weeks.actual_hours), 0
            ) as actual_total,
            COALESCE(
              (SUM(work_weeks.actual_hours) - SUM(work_weeks.estimated_hours)), 0
            ) as diff
          FROM assignments
          JOIN work_weeks ON assignments.id = work_weeks.assignment_id
          GROUP BY user_id
        ) as derp
      GROUP BY user_id
    }
  end

  def down
    execute "DROP VIEW staffplans_totals_view;"
  end
end
