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

    field :clients, [Types::StaffPlan::ClientType], null: false
    def clients
      context[:current_user].current_company.clients.all
    end

    field :project_assignments, [Types::StaffPlan::AssignmentType], null: false do
      argument :project_id, ID, required: true, description: "ID of the project to fetch assignments for."
    end

    def project_assignments(project_id: nil)
      context[:current_company]
        .projects
        .find(project_id)
        .assignments
        .all
    end

    field :user_assignments, [Types::StaffPlan::AssignmentType], null: false do
      argument :user_id, ID, required: false,
               description: "ID of the user to fetch assignments for. The current user's assignments will be returned if this argument is not provided."
    end
    def user_assignments(user_id: nil)
      target = if user_id.present?
        context[:current_company].users.find(user_id)
      else
        context[:current_user]
      end

      target.assignments.all
    end

    field :users, [Types::StaffPlan::UserType], null: false
    def users
      context[:current_user].current_company.users.all
    end
  end
end
