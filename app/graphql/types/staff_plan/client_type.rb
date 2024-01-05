# frozen_string_literal: true

module Types
  module StaffPlan
    class ClientType < Types::BaseObject
      field :id, ID, null: false
      field :name, String, null: false
      field :description, String, null: true
      field :status, String, null: false
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

      field :projects, [Types::StaffPlan::ProjectType], null: false

      def projects
        object.projects
      end
    end
  end
end
