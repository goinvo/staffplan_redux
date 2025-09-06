# frozen_string_literal: true

class AddStartsAndEndsOnToAssignments < ActiveRecord::Migration[7.1]
  def change
    add_column :assignments, :starts_on, :date
    add_column :assignments, :ends_on, :date
  end
end
