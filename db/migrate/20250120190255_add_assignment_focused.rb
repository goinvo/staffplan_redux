# frozen_string_literal: true

class AddAssignmentFocused < ActiveRecord::Migration[8.0]
  def change
    add_column :assignments, :focused, :boolean, default: true, null: false
  end
end
