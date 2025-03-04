class User < ApplicationRecord
  belongs_to :current_company, class_name: 'Company', foreign_key: :current_company_id
  has_many :memberships, dependent: :destroy
  has_many :companies, through: :memberships
  has_many :assignments, dependent: :destroy
  has_many :projects, through: :assignments
  has_many :work_weeks, through: :assignments

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end

  validates :name, presence: true
  validates :current_company, presence: true
  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }

  passwordless_with :email

  has_paper_trail

  def owner?(company:)
    memberships.find_by(company:).role == Membership::OWNER
  end

  def admin?(company:)
    memberships.find_by(company:).role == Membership::ADMIN
  end

  def role(company:)
    memberships.find_by(company:).role
  end

  def status(company:)
    memberships.find_by(company:).status
  end

  def inactive?(company:)
    memberships.find_by(company:).inactive?
  end

  def toggle_status!(company:)
    membership = memberships.find_by!(company:)
    membership.update!(status: membership.active? ? Membership::INACTIVE : Membership::ACTIVE)

    Stripe::SyncCustomerSubscriptionJob.perform_later(company)
  end
end
