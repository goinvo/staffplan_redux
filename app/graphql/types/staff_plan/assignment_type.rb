# frozen_string_literal: true

module Types
  module StaffPlan
    class AssignmentType < Types::BaseObject
      field :id, ID, null: false
      field :user, Types::StaffPlan::UserType, null: false
      field :project, Types::StaffPlan::ProjectType, null: false
      field :status, String, null: false
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

      field :work_weeks, [Types::StaffPlan::WorkWeekType], null: false

      def work_weeks
        object.work_weeks
      end
    end
  end
end
