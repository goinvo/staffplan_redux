# frozen_string_literal: true

class CreateAssignments < ActiveRecord::Migration[7.1]
  def change
    create_table :assignments do |t|
      t.references :user,     null: false
      t.references :project,  null: false
      t.string :status,             null: false, default: 'proposed'

      t.timestamps
    end
  end
end
