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

      field :companies, [Types::StaffPlan::CompanyType], null: false

      def companies
        object.companies
      end

      field :assignments, [Types::StaffPlan::AssignmentType], null: false

      def assignments
        object.assignments
      end

      field :projects, [Types::StaffPlan::ProjectType], null: false

      def projects
        object.projects
      end
    end
  end
end
