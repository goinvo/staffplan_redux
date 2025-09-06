# frozen_string_literal: true

class Client < ApplicationRecord
  belongs_to :company
  has_many :projects, dependent: :destroy

  has_paper_trail

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end

  ACTIVE = 'active'
  ARCHIVED = 'archived'

  VALID_STATUSES = [ACTIVE, ARCHIVED].freeze

  validates :company_id, uniqueness: { scope: :name }, presence: true # rubocop:disable Rails/RedundantPresneceValidationOnBelongsTo
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
end
