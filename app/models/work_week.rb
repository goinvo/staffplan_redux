class WorkWeek < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :assignment
  delegate :user, to: :assignment
  delegate :project, to: :assignment
  
  validates_presence_of :assignment, :beginning_of_week
  validates_numericality_of :estimated_hours, :actual_hours, greater_than_or_equal_to: 0, allow_nil: true
  
  before_validation :set_beginning_of_week_if_blank

  ################################# SCOPES ####################################

  scope :with_hours, lambda { where("estimated_hours IS NOT NULL OR actual_hours IS NOT NULL") }
  
  def proposed?
    project.assignments.where(user_id: user.id).first.try(:proposed?) || false
  end
end
