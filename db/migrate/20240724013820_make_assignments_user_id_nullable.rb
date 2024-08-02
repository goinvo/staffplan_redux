class MakeAssignmentsUserIdNullable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :assignments, :user_id, true
  end
end
