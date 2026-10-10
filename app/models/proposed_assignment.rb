# frozen_string_literal: true

class ProposedAssignment
  include ActiveModel::Model

  attr_accessor :company, :user, :client_name, :project_name
  attr_reader :assignment

  validate :names_present
  validate :not_already_assigned

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      client = existing_client || company.clients.create!(name: client_name.strip)
      project = existing_project(client) || client.projects.create!(name: project_name.strip)
      @assignment = project.assignments.create!(user:, status: Assignment::PROPOSED)
    end
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.record.errors.full_messages.to_sentence)
    false
  end

  private

  def existing_client
    company.clients.find_by('lower(name) = ?', client_name.strip.downcase)
  end

  def existing_project(client)
    client&.projects&.find_by('lower(name) = ?', project_name.strip.downcase)
  end

  def names_present
    errors.add(:client_name, 'Client is required') if client_name.blank?
    errors.add(:project_name, 'Project name is required') if project_name.blank?
  end

  def not_already_assigned
    return if client_name.blank? || project_name.blank?

    project = existing_project(existing_client)
    errors.add(:project_name, 'Project is already in the Staff plan') if project&.assignments&.exists?(user:)
  end
end
