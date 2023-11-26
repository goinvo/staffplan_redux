class CreateWorkWeeks < ActiveRecord::Migration[7.1]
  def change
    create_table :work_weeks do |t|
      t.references :assignment,   null: false
      t.integer :cweek,                 null: false
      t.integer :year,                  null: false
      t.decimal :beginning_of_week,     null: false, precision: 15, scale: 0
      t.integer :estimated_hours,       null: false, default: 0
      t.integer :actual_hours,          null: false, default: 0

      t.timestamps
    end

    add_index :work_weeks, [:assignment_id, :beginning_of_week], unique: true
  end
end
