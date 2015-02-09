class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :confirmable,# :lockable,
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable

  self.primary_key = "id"

  has_paper_trail

  has_many :assignments, :dependent => :destroy do
    def for_company(company)
      self.select do |a|
        a.project.company_id == company.id
      end
    end
  end
  has_one :user_preferences, :dependent => :destroy
  has_many :projects, :through => :assignments
  has_many :memberships, :dependent => :destroy
  has_many :companies, :through => :memberships

  has_one :staffplans_totals_view
  has_many :staffplans_work_weeks_view

  has_many :user_projects, class_name: "UserProjectsView"
  has_many :sent_invitations, foreign_key: "sender", class_name: "Invite"

  has_many :received_invitations, foreign_key: "email", primary_key: "email", class_name: "Invite"
  has_many :user_projects, class_name: "UserProjectsView" do
    def for_company(company)
      where(company_id: company.id)
    end
  end

  # after_update do |user|
  #   terminator = user.versions.last.try(:terminator)
  #   if terminator.present? && (terminator.to_i != user.id)
  #     User.where(:id => terminator.to_i).first.try(&:update_timestamp!)
  #   end
  # end

  validates_presence_of :email, :first_name, :last_name
  validates_uniqueness_of :email
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/

  before_validation :initialize_user_preferences

  def initialize_user_preferences
    self.build_user_preferences if self.user_preferences.nil?
  end

  def full_name
    [first_name, last_name].join(" ")
  end

  def current_company
    companies.where(id: current_company_id).first
  end

  def current_company=(company)
    return false unless self.companies.include?(company)
    self.current_company_id = company.id
    self.save
  end

  def selectable_companies
    Company.where(id: memberships.where(disabled: false).select("memberships.company_id").pluck(:id))
  end

  def admin_of?(company)
    self.memberships.where(company: company).first.permissions?(:admin)
  end
end
