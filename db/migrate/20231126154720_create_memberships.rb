class CreateMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :memberships do |t|
      t.integer :company_id, null: false
      t.integer :user_id, null: false
      t.string :status, null: false
      t.string :role, null: false

      t.timestamps
    end

    add_index :memberships, [:company_id, :user_id], unique: true
  end
end
