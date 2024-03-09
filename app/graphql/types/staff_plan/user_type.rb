# frozen_string_literal: true

module Types
  module StaffPlan
    class UserType < Types::BaseObject
      field :id, ID, null: false
      field :name, String, null: false
      field :email, String, null: false
      field :current_company_id, ID, null: true
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

      field :companies, [Types::StaffPlan::CompanyType], null: false, description: "Fetches all companies for the current user."

      def companies
        object.companies
      end

      field :assignments, [Types::StaffPlan::AssignmentType], null: false, description: "Fetches all of the user's assignments for the current company."

      def assignments
        object.assignments.where(project_id: object.current_company.projects.map(&:id))
      end

      field :projects, [Types::StaffPlan::ProjectType], null: false, description: "Fetches all projects for the current user for the current company."

      def projects
        object.projects.where(client_id: object.current_company.clients.map(&:id))
      end
    end
  end
end
