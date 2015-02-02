class StaffplanListWorkWeek < ActiveRecord::Base
  self.primary_key = :user_id
  belongs_to :user
  belongs_to :assignment
end
