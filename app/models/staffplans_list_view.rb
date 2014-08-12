class StaffplansListView < ActiveRecord::Base
  self.table_name = "staffplan_list_view"
  
  belongs_to :users
end
