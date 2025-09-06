# frozen_string_literal: true

class AddCurrentCompanyToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :current_company_id, :integer, null: false
  end
end
