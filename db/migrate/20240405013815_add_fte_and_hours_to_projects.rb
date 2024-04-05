class AddFteAndHoursToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :fte, :decimal, precision: 8, scale: 2
    add_column :projects, :hours, :integer
  end
end
