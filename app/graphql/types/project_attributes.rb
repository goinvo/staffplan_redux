# frozen_string_literal: true

module Types
  class ProjectAttributes < Types::BaseInputObject
    description 'Attributes for creating or updating a project'
    argument :assignments, [Types::AssignmentAttributes], required: false, description: 'Assignments for this project. See upsertAssignment to create a single assignment for existing projects.'
    argument :client_id, ID, required: false, description: 'The ID of the client for this project.'
    argument :cost, Float, required: false, description: 'The cost of the project.'
    argument :ends_on, GraphQL::Types::ISO8601Date, required: false, description: 'The date this project ends.'
    argument :fte, Float, required: false, description: 'The number of full time employees that will be assigned to this project.'
    argument :hourly_rate, Integer, required: false, description: 'The hourly rate for this project.'
    argument :hours, Integer, required: false, description: 'The expected number of billable hours expected for this project.'
    argument :id, ID, required: false, description: 'The ID of the project to update.'
    argument :name, String, required: false, description: 'The name of the project.'
    argument :payment_frequency, String, required: false, description: 'The frequency of payment for the project.'
    argument :rate_type, String, required: false, description: 'The type of rate for this project.'
    argument :starts_on, GraphQL::Types::ISO8601Date, required: false, description: 'The date this project starts.'
    argument :status, String, required: false, description: 'The status of the project.'
  end
end
