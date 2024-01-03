# frozen_string_literal: true

module Types
  module StaffPlan
    class WorkWeekType < Types::BaseObject
      field :id, ID, null: false
      field :assignment_id, Integer, null: false
      field :cweek, Integer, null: false
      field :year, Integer, null: false
      field :beginning_of_week, Integer, null: false
      field :estimated_hours, Integer, null: false
      field :actual_hours, Integer, null: false
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

      field :user, Types::StaffPlan::UserType, null: false

      def user
        object.user
      end

      field :project, Types::StaffPlan::ProjectType, null: false

      def project
        object.project
      end
    end
  end
end
