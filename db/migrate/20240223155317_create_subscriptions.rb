# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.references :company, null: false, foreign_key: true
      t.string :stripe_id
      t.string :stripe_price_id
      t.string :customer_name
      t.string :customer_email
      t.integer :plan_amount
      t.integer :quantity
      t.string :credit_card_brand
      t.string :credit_card_last_four
      t.string :credit_card_exp_month
      t.string :credit_card_exp_year
      t.date :current_period_start
      t.date :current_period_end
      t.timestamps
    end
  end
end
