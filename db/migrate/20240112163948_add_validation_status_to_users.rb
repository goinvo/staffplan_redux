class AddValidationStatusToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :validation_status, :string, null: false, default: "pending"
  end
end
