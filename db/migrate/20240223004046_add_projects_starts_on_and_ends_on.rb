class AddProjectsStartsOnAndEndsOn < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :starts_on, :date
    add_column :projects, :ends_on, :date
  end
end
