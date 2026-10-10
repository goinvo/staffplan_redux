# frozen_string_literal: true

module Timeline
  class ProjectSort < AssignmentSort
    def initialize(column: 'project', direction: 'asc') = super

    private

    def client_name(project) = project.client.name.downcase

    def project_name(project) = project.name.downcase
  end
end
