# frozen_string_literal: true

module Types
  module StaffPlan
    class AssignmentType < Types::BaseObject
      field :id, ID, null: false

      field :assigned_user, Types::StaffPlan::UserType, null: false, description: 'The user assigned to this assignment'
      def assigned_user
        object.user
      end

      field :project, Types::StaffPlan::ProjectType, null: false, description: 'The project this assignment is for'
      field :status, Enums::AssignmentStatus, null: false, description: 'The status of the assignment'
      field :starts_on, GraphQL::Types::ISO8601Date, null: true, description: 'The date the assignment starts'
      field :ends_on, GraphQL::Types::ISO8601Date, null: true, description: 'The date the assignment ends'
      field :estimated_weekly_hours, Integer, null: true, description: 'The estimated weekly hours for this assignment'
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

      field :work_weeks, [Types::StaffPlan::WorkWeekType], null: false, description: 'The work weeks for this assignment'

      def work_weeks
        object.work_weeks
      end
    end
  end
end
