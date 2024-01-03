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

    field :assignments, [Types::StaffPlan::AssignmentType], null: false
    def assignments
      User.first.assignments.all
    end

    field :users, [Types::StaffPlan::UserType], null: false
    def users
      Company.first.users.all
    end
  end
end
