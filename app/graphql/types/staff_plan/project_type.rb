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
      field :can_be_deleted, Boolean, null: false, description: 'Whether the assignment can be deleted'
      field :assignments, [Types::StaffPlan::AssignmentType], null: false

      def assigmnents
        object.assignments.include(:work_weeks)
      end

      field :users, [Types::StaffPlan::UserType], null: false

      def users
        object.users
      end

      field :work_weeks, [Types::StaffPlan::WorkWeekType], null: false do
        argument :start_date, GraphQL::Types::ISO8601Date, required: false, description: 'Optional start date to filter work weeks'
        argument :end_date, GraphQL::Types::ISO8601Date, required: false, description: 'Optional end date to filter work weeks'
      end

      def work_weeks(start_date: nil, end_date: nil)
        scope = object.work_weeks

        if start_date.present?
          scope = scope.where('year >= ?', start_date.year).or(scope.where('cweek >= ? AND year >= ?', start_date.cweek, start_date.year))
        end

        if end_date.present?
          scope = scope.where('year <= ?', end_date.year).or(scope.where('cweek <= ? AND year <= ?', end_date.cweek, end_date.year))
        end

        scope
      end

      def can_be_deleted
        object.can_be_deleted?
      end
    end
  end
end
