class StaffplansTotalsView < ActiveRecord::Base
  self.table_name = "staffplans_totals_view"
  self.primary_key = :user_id
  belongs_to :user
end
