class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.integer :sender_id, null: false
      t.integer :company_id, null: false
      t.string :email, null: false
      t.string :aasm_state, null: false

      t.timestamps
    end
  end
end
