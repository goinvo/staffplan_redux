class StaffplansListView < ActiveRecord::Base
  self.table_name = "staffplans_list_view"
  
  belongs_to :users
end
