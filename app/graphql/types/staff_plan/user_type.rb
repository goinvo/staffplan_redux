# frozen_string_literal: true

module Types
  module StaffPlan
    class UserType < Types::BaseObject
      field :id, ID, null: false
      field :name, String, null: false
      field :email, String, null: false
      field :current_company, Types::StaffPlan::CompanyType, null: true

      field :avatar_url, String, null: false
      def avatar_url
        AvatarHelper.new(target: object).image_url
      end

      field :companies, [Types::StaffPlan::CompanyType], null: false, description: "Fetches all companies for the current user."

      def companies
        object.companies
      end

      field :assignments, [Types::StaffPlan::AssignmentType], null: false, description: "Fetches all of the user's assignments for the current company."

      def assignments
        object.assignments.includes(:work_weeks, project: :client).where(project_id: context[:current_company].projects.map(&:id))
      end

      field :projects, [Types::StaffPlan::ProjectType], null: false, description: "Fetches all projects for the current user for the current company."

      def projects
        object.projects.includes(assignments: [:work_weeks, project: :client]).where(client_id: context[:current_company].clients.map(&:id))
      end

      field :role, String, null: false, description: "The role of the user in the current_company"
      def role
        object.role(company: context[:current_company])
      end

      field :is_active, Boolean, null: false, description: "Whether the user is an active member of the current company."
      def is_active
        object.status(company: context[:current_company]) == Membership::ACTIVE
      end

      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    end
  end
end
