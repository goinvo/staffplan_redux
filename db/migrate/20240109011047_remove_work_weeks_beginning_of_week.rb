class RemoveWorkWeeksBeginningOfWeek < ActiveRecord::Migration[7.1]
  def change
    remove_column :work_weeks, :beginning_of_week, :integer
  end
end
