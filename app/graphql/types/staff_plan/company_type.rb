# frozen_string_literal: true

module Types
  module StaffPlan
    class CompanyType < Types::BaseObject
      field :id, ID, null: false
      field :name, String, null: false

      field :avatar_url, String, null: false
      def avatar_url
        AvatarHelper.new(target: object).image_url
      end

      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

      field :projects, [Types::StaffPlan::ProjectType], null: false

      def projects
        object.projects
      end

      field :clients, [Types::StaffPlan::ClientType], null: false

      def clients
        object.clients
      end

      field :users, [Types::StaffPlan::UserType], null: false do
        argument :user_id, ID, required: false, description: "Filter users by ID"
      end

      def users(user_id: nil)
        scope = object.users

        if user_id.present?
          scope = scope.where(id: user_id)
        end

        scope
      end
    end
  end
end
