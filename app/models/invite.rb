class Invite < ActiveRecord::Base
  include AASM

  belongs_to :sender, class_name: "User"
  belongs_to :company

  aasm do
    state :new, initial: true
    state :accepted
    state :declined

    event :accept do
      transitions from: :new, to: :accepted
    end

    event :decline do
      transitions from: :new, to: :declined
    end
  end

  validates :sender, :company, :email, presence: true
  validates :email, uniqueness: { scope: "company_id", message: "This invite already exists." }
  validate :employee_doesnt_exist_already, if: Proc.new { |i| i.company.present? }

  scope :pending, -> { where(aasm_state: :new) }

  def employee_doesnt_exist_already
    company.memberships.each do |membership|
      next if membership.new_record?
      if membership.user.email == email
        errors.add(:email, "Employee with this email already exists for this company.")
      end
    end
  end

  def send_response_email(current_user)
    InviteEmails.response_email(current_user, self).deliver_now
  end

  def email_invitation
    if User.exists?(email: email)
      InviteEmails.existing_user_invite(self).deliver_now
    else
      InviteEmails.new_user_invite(self).deliver_now
    end
  end
end
