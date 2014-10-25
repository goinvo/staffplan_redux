class DeviseCreateUsers < ActiveRecord::Migration
  def up
    
    # robnote: we're extending the existing database to support devise.
    # I changed this to add columns rather than wipe/recreate the users table.
    # original colunn def above, new one below.
    
    ## Database authenticatable
    
    # t.string :email,              null: false, default: ""
    change_column(:users, :email, :string, null: false, default: "")
    
    # t.string :encrypted_password, null: false, default: ""
    add_column(:users, :encrypted_password, :string, null: false, default: "")
    
    ## Recoverable
    
    # t.string   :reset_password_token
    add_column(:users, :reset_password_token, :string)
    
    # t.datetime :reset_password_sent_at
    add_column(:users, :reset_password_sent_at, :datetime)

    ## Rememberable
    
    # t.datetime :remember_created_at
    add_column(:users, :remember_created_at, :datetime)

    ## Trackable
    
    # t.integer  :sign_in_count, default: 0, null: false
    add_column(:users, :sign_in_count, :integer, default: 0, null: false)
    
    # t.datetime :current_sign_in_at
    add_column(:users, :current_sign_in_at, :datetime)
    
    # t.datetime :last_sign_in_at
    add_column(:users, :last_sign_in_at, :datetime)
    
    # t.string   :current_sign_in_ip
    add_column(:users, :current_sign_in_ip, :string)
    
    # t.string   :last_sign_in_ip
    add_column(:users, :last_sign_in_ip, :string)

    ## Confirmable
    
    # t.string   :confirmation_token
    add_column(:users, :confirmation_token, :string)
    
    # t.datetime :confirmed_at
    add_column(:users, :confirmed_at, :datetime)
    
    # t.datetime :confirmation_sent_at
    add_column(:users, :confirmation_sent_at, :datetime)
    
    # t.string   :unconfirmed_email # Only if using reconfirmable
    add_column(:users, :unconfirmed_email, :string)

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
  end
  
  def down
    # TODO: make this reversible
  end
end
