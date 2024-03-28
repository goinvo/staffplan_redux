class UpdateProjectsDefaultStatusEnumValue < ActiveRecord::Migration[7.1]
  def change
    change_column_default :projects, :status, from: 'proposed', to: 'unconfirmed'
  end
end
