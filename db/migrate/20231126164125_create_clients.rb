class CreateClients < ActiveRecord::Migration[7.1]
  def change
    create_table :clients do |t|
      t.references :company,  null: false
      t.string :name,               null: false
      t.text :description
      t.string :status,             null: false, default: 'active'

      t.timestamps
    end
  end
end
