class CreateRegistrations < ActiveRecord::Migration[7.1]
  def change
    create_table :registrations do |t|
      t.string :email, null: false
      t.string :name, null: false
      t.datetime :expires_at, null: false
      t.datetime :registered_at
      t.string :token_digest, null: false
      t.uuid :identifier, null: false, default: "gen_random_uuid()", index: { unique: true }
      t.integer :user_id # populated after user is created
      t.string :ip_address, null: false, limit: 15
      t.timestamps
    end
  end
end
