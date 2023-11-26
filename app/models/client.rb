class Client < ApplicationRecord
  belongs_to :company
  has_many :projects, dependent: :destroy

  validates :company_id, presence: true, uniqueness: { scope: :name }
  validates :name, presence: true, uniqueness: { scope: :company_id }
  validates :status, presence: true, inclusion: { in: %w(active archived) }
end
