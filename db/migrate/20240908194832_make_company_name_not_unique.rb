class MakeCompanyNameNotUnique < ActiveRecord::Migration[7.2]
  def change
    remove_index :companies, :name
  end
end
