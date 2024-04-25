class AddProjectsHourlyRate < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :hourly_rate, :integer, default: 0, null: false
  end
end
