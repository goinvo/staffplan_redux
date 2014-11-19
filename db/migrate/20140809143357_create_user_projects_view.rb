class CreateUserProjectsView < ActiveRecord::Migration
  def up
    execute %{
      CREATE OR REPLACE VIEW user_projects_view AS
        SELECT
          users.id AS user_id,
          projects.id AS project_id,
          projects.company_id AS company_id,
          assignments.id AS assignment_id,
          assignments.proposed AS assignment_proposed,
          assignments.archived AS assignment_archived,
          clients.id AS client_id,
          clients.name AS client_name,
          projects.name AS project_name,
          projects.active AS project_active
        FROM users
        INNER JOIN assignments ON assignments.user_id = users.id
        INNER JOIN projects ON assignments.project_id = projects.id
        INNER JOIN clients ON projects.client_id = clients.id
        ORDER BY user_id, client_name DESC
    }
  end

  def down
    execute "DROP VIEW user_projects_view;"
  end
end
