class AddPaymentMetadataToSubscriptions < ActiveRecord::Migration[7.1]
  def change
    add_column :subscriptions, :payment_method_type, :string
    add_column :subscriptions, :payment_metadata, :jsonb, default: {}
    remove_column :subscriptions, :credit_card_brand, :string
    remove_column :subscriptions, :credit_card_last_four, :string
    remove_column :subscriptions, :credit_card_exp_month, :string
    remove_column :subscriptions, :credit_card_exp_year, :string
  end
end
