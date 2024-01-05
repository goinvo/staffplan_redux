# frozen_string_literal: true

module Types
  module StaffPlan
    class ProjectType < Types::BaseObject
      field :id, ID, null: false
      field :client, Types::StaffPlan::ClientType, null: false
      field :name, String, null: false
      field :status, String, null: false
      field :payment_frequency, String, null: false
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

      field :assignments, [Types::StaffPlan::AssignmentType], null: false

      def assigmnents
        object.assignments
      end

      field :users, [Types::StaffPlan::UserType], null: false

      def users
        object.users
      end

      field :work_weeks, [Types::StaffPlan::WorkWeekType], null: false

      def work_weeks
        object.work_weeks
      end
    end
  end
end
