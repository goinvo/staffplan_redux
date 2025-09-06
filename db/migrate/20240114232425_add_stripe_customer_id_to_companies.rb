# frozen_string_literal: true

class AddStripeCustomerIdToCompanies < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :stripe_id, :string
  end
end
