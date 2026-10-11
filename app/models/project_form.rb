# frozen_string_literal: true

class ProjectForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :project_name, :string
  attribute :client_name, :string
  attribute :hours, :string
  attribute :starts_on, :date
  attribute :ends_on, :date
  attribute :archived, :boolean, default: false

  attr_accessor :company, :user
  attr_reader :project

  validate :names_present
  validate :name_available
  validate :hours_numeric
  validate :dates_in_order

  def self.for(project)
    new(
      project:,
      company: project.company,
      project_name: project.name,
      client_name: project.client.name,
      hours: project.hours&.to_s,
      starts_on: project.starts_on,
      ends_on: project.ends_on,
      archived: project.archived?,
    )
  end

  def initialize(project: nil, **)
    @project = project
    super(**)
  end

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      client = existing_client || company.clients.create!(name: client_name.strip)

      if project
        project.update!(client:, name: project_name.strip, hours: target_hours, starts_on:, ends_on:, status:)
      else
        @project = client.projects.create!(name: project_name.strip, hours: target_hours, starts_on:, ends_on:)
        @project.assignments.create!(user:, status: Assignment::PROPOSED) if user
      end
    end
    true
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.record.errors.full_messages.to_sentence)
    false
  end

  private

  def dates_in_order
    errors.add(:ends_on, "End date can't be before the start date") if starts_on && ends_on && ends_on < starts_on
  end

  def existing_client
    company.clients.named(client_name).first
  end

  def hours_numeric
    errors.add(:hours, 'Target hours must be a whole number') unless hours.to_s.delete(',').strip.match?(/\A\d*\z/)
  end

  def name_available
    return if client_name.blank? || project_name.blank?

    client = existing_client
    return if client.nil?

    errors.add(:project_name, 'Project name already in use') if client.projects.named(project_name).where.not(id: project).exists?
  end

  def names_present
    errors.add(:client_name, 'Client is required') if client_name.blank?
    errors.add(:project_name, 'Project name is required') if project_name.blank?
  end

  def status
    if archived
      Project::ARCHIVED
    elsif project.archived?
      Project::UNCONFIRMED
    else
      project.status
    end
  end

  def target_hours
    hours.to_s.delete(',').strip.presence&.to_i
  end
end
