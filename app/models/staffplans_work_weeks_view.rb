class StaffplansWorkWeeksView < ActiveRecord::Base
  self.table_name = "staffplans_work_weeks_view"
  self.primary_key = :user_id
  
  belongs_to :user
  belongs_to :assignment
end
