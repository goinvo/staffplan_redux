class User < ApplicationRecord
  belongs_to :current_company, class_name: 'Company', foreign_key: :current_company_id
  has_many :memberships, dependent: :destroy
  has_many :companies, through: :memberships
  has_many :assignments, dependent: :destroy
  has_many :projects, through: :assignments
  has_many :work_weeks, through: :assignments

  validates :name, presence: true
  validates :current_company, presence: true
  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }

  passwordless_with :email

  def owner?
    memberships.find_by(company: current_company).role == Membership::OWNER
  end
end
