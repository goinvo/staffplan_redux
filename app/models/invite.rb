class Invite < ActiveRecord::Base
  include AASM

  belongs_to :sender, class_name: "User"
  belongs_to :company

  aasm do
    state :new, initial: true
    state :accepted
    state :declined

    event :accept, after: Proc.new { response_email('accepted') } do
      transitions from: :new, to: :accepted
    end

    event :decline, after: Proc.new { response_email('declined') } do
      transitions from: :new, to: :declined
    end
  end

  validates :sender, :company, :email, presence: true
  validates :email, uniqueness: { scope: "company_id", message: "This invite already exists." }
  validate :employee_doesnt_exist_already, if: Proc.new { |i| i.company.present? }

  def status
    self.aasm.states
  end

  def employee_doesnt_exist_already
    company.memberships.each do |membership|
      if membership.user.email == email
        errors.add(:email, "Employee with this email already exists for this company.")
      end
    end
  end

  def response_email(state)
    #TODO: send an email to the sender, letting them know the invitation was responded to
  end
end
