# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :node, Types::NodeType, null: true, description: "Fetches an object given its ID." do
      argument :id, ID, required: true, description: "ID of the object."
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [Types::NodeType, null: true], null: true, description: "Fetches a list of objects given a list of IDs." do
      argument :ids, [ID], required: true, description: "IDs of the objects."
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    field :viewer, Types::StaffPlan::UserType, null: true, description: "The currently authenticated user."
    def viewer
      context[:current_user]
    end

    field :current_company, Types::StaffPlan::CompanyType, null: true, description: "The company in scope for all other company-related queries."
    def current_company
      Company.includes(:projects, users: :avatar_attachment).find(context[:current_company].id)
    end

    field :clients, [Types::StaffPlan::ClientType], null: false, description: "Fetches all clients for the current company."
    def clients
      context[:current_user].current_company.clients.all
    end

    field :projects, [Types::StaffPlan::ProjectType], null: false, description: "Fetches all projects for the current company."
    def projects
      context[:current_company]
      .projects
      .all
    end

    field :project_assignments, [Types::StaffPlan::AssignmentType], null: false, description: "Fetches all assignments for the company's projects."do
      argument :project_id, ID, required: true, description: "Optional: ID of the company's project to fetch assignments for."
    end

    def project_assignments(project_id: nil)
      context[:current_company]
        .projects
        .find(project_id)
        .assignments
        .all
    end

    field :user_assignments, [Types::StaffPlan::AssignmentType], null: false, description: "Fetches all of the project assignments for the current user." do
      argument :user_id, ID, required: false,
               description: "Optional: ID of the user to fetch assignments for."
    end
    def user_assignments(user_id: nil)
      target = if user_id.present?
        context[:current_company].users.find(user_id)
      else
        context[:current_user]
      end

      target.assignments.all
    end

    field :users, [Types::StaffPlan::UserType], null: false, description: "Fetches all users for the current company." do
      argument :user_id, ID, required: false, description: "Optional: ID of the user to fetch."
    end
    def users(user_id: nil)
      scope = context[:current_user]
              .current_company
              .users
      if user_id.present?
        scope = scope.where(id: user_id)
      end

      scope.all
    end
  end
end
