# frozen_string_literal: true

module Types
  module StaffPlan
    class ProjectType < Types::BaseObject
      field :id, ID, null: false
      field :client, Types::StaffPlan::ClientType, null: false
      field :name, String, null: false
      field :status,  Enums::ProjectStatus, null: false
      field :cost, Float, null: false
      field :payment_frequency, Enums::ProjectPaymentFrequency, null: false
      field :fte, Float, null: true
      field :hours, Integer, null: true
      field :rate_type, String, null: true
      field :hourly_rate, Integer, null: false
      field :starts_on, GraphQL::Types::ISO8601Date, null: true
      field :ends_on, GraphQL::Types::ISO8601Date, null: true
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

      field :assignments, [Types::StaffPlan::AssignmentType], null: false

      def assigmnents
        object.assignments.include(:work_weeks)
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
