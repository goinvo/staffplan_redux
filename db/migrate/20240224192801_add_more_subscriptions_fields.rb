# frozen_string_literal: true

class AddMoreSubscriptionsFields < ActiveRecord::Migration[7.1]
  def change
    add_column :subscriptions, :status, :string
    add_column :subscriptions, :trial_end, :datetime
  end
end
