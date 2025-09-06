# frozen_string_literal: true

class CreateProjects < ActiveRecord::Migration[7.1]
  def change
    create_table :projects do |t|
      t.references :client, null: false
      t.string :name,                     null: false
      t.string :status,                   null: false, default: 'proposed'
      t.decimal :cost,                    null: false, precision: 12, scale: 2, default: 0.0
      t.string :payment_frequency,        null: false, default: 'monthly'

      t.timestamps
    end

    add_index :projects, %i[client_id name], unique: true
  end
end
