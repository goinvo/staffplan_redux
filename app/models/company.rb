class Company < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :clients, dependent: :destroy
  has_many :projects, through: :clients
  has_many :work_weeks, through: :projects
  has_many :assignments, through: :projects

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
