# frozen_string_literal: true

class AddDefaultPaymentMethodToSubscriptions < ActiveRecord::Migration[7.1]
  def change
    add_column :subscriptions, :default_payment_method, :string
  end
end
