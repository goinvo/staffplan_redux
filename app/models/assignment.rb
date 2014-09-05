class Assignment < ActiveRecord::Base

  has_many :work_weeks, dependent: :destroy

  belongs_to :project
  belongs_to :user

  validates_uniqueness_of :project_id, scope: :user_id, unless: Proc.new { |model| model.user_id.blank? } # TBD user
  validates_presence_of :project
end
