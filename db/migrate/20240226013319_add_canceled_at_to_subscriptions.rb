class AddCanceledAtToSubscriptions < ActiveRecord::Migration[7.1]
  def change
    add_column :subscriptions, :canceled_at, :timestamp
  end
end
