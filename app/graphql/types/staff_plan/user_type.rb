# frozen_string_literal: true

module Types
  module StaffPlan
    class UserType < Types::BaseObject
      field :email, String, null: false
      field :id, ID, null: false

      field :companies, [Types::StaffPlan::CompanyType], null: false, description: 'Fetches all companies for the current user.'

      field :assignments, [Types::StaffPlan::AssignmentType], null: false, description: "Fetches all of the user's assignments for the current company."

      field :projects, [Types::StaffPlan::ProjectType], null: false, description: 'Fetches all projects for the current user for the current company.'

      field :role, String, null: false, description: 'The role of the user in the current_company'

      field :is_active, Boolean, null: false, description: 'Whether the user is an active member of the current company.'

      field :created_at, GraphQL::Types::ISO8601DateTime, null: false

      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

      field :current_company, Types::StaffPlan::CompanyType, null: true
      field :name, String, null: false

      field :avatar_url, String, null: false
      def assignments
        object.assignments.includes(:work_weeks, project: :client).where(project_id: context[:current_company].projects.map(&:id))
      end

      def avatar_url
        AvatarHelper.new(target: object).image_url
      end

      delegate :companies, to: :object

      def is_active
        object.status(company: context[:current_company]) == Membership::ACTIVE
      end

      def projects
        object.projects.includes(assignments: [:work_weeks, { project: :client }]).where(client_id: context[:current_company].clients.map(&:id))
      end

      def role
        object.role(company: context[:current_company])
      end
    end
  end
end
