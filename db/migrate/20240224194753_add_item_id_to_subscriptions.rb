class AddItemIdToSubscriptions < ActiveRecord::Migration[7.1]
  def change
    add_column :subscriptions, :item_id, :string
  end
end
