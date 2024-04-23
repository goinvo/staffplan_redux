class AddProjectsRateType < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :rate_type, :string
  end
end
