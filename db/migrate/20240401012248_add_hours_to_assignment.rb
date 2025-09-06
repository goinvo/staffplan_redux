# frozen_string_literal: true

class AddHoursToAssignment < ActiveRecord::Migration[7.1]
  def change
    add_column :assignments, :estimated_weekly_hours, :integer
  end
end
