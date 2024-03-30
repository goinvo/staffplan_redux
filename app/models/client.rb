class Client < ApplicationRecord
  belongs_to :company
  has_many :projects, dependent: :destroy

  has_paper_trail

  ACTIVE = 'active'.freeze
  ARCHIVED = 'archived'.freeze

  VALID_STATUSES = [ACTIVE, ARCHIVED].freeze

  validates :company_id, presence: true, uniqueness: { scope: :name }
  validates :name, presence: true, uniqueness: { scope: :company_id }
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }

  scope :active, -> { where(status: 'active') }
  scope :archived, -> { where(status: 'archived') }

  def active?
    status == ACTIVE
  end

  def archived?
    status == ARCHIVED
  end
  def toggle_archived!
    new_status = active? ? Client::ARCHIVED : Client::ACTIVE

    Client.transaction do
      update!(status: new_status)

      # archive all projects
      if new_status == Client::ARCHIVED
        projects.update_all(status: Project::ARCHIVED)
      end
    end
  end

  def has_gravatar?
    false
  end
end
