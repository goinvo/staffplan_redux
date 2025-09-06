# frozen_string_literal: true

class RemoveUsersValidationStatus < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :validation_status
  end
end
