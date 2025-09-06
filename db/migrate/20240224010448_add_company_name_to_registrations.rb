# frozen_string_literal: true

class AddCompanyNameToRegistrations < ActiveRecord::Migration[7.1]
  def change
    add_column :registrations, :company_name, :string
  end
end
