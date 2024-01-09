class ChangeWorkWeekUniquenessConstraints < ActiveRecord::Migration[7.1]
  def change
    remove_index :work_weeks, name: "index_work_weeks_on_assignment_id_and_beginning_of_week"
    add_index :work_weeks, [:assignment_id, :cweek, :year], unique: true
  end
end
