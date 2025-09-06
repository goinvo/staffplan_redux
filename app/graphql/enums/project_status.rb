# frozen_string_literal: true

module Enums
  class ProjectStatus < Types::BaseEnum
    value Project::UNCONFIRMED, value: Project::UNCONFIRMED.downcase, description: 'The project is unconfirmed.'
    value Project::CONFIRMED, value: Project::CONFIRMED.downcase, description: 'The project is confirmed.'
    value Project::ARCHIVED, value: Project::ARCHIVED.downcase, description: 'The project is archived and is no longer active.'
    value Project::CANCELLED, value: Project::CANCELLED.downcase, description: 'The project is canceled.'
    value Project::COMPLETED, value: Project::COMPLETED.downcase, description: 'The project is completed.'
  end
end
