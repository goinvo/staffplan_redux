# frozen_string_literal: true

module Types
  module StaffPlan
    class ProjectType < Types::BaseObject
      field :client, Types::StaffPlan::ClientType, null: false
      field :id, ID, null: false

      field :users, [Types::StaffPlan::UserType], null: false

      field :work_weeks, [Types::StaffPlan::WorkWeekType], null: false do
        argument :end_date, GraphQL::Types::ISO8601Date, required: false, description: 'Optional end date to filter work weeks'
        argument :start_date, GraphQL::Types::ISO8601Date, required: false, description: 'Optional start date to filter work weeks'
      end

      field :assignments, [Types::StaffPlan::AssignmentType], null: false
      field :can_be_deleted, Boolean, null: false, description: 'Whether the assignment can be deleted', method: :can_be_deleted?
      field :cost, Float, null: false
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :ends_on, GraphQL::Types::ISO8601Date, null: true
      field :fte, Float, null: true
      field :hourly_rate, Integer, null: false
      field :hours, Integer, null: true
      field :name, String, null: false
      field :payment_frequency, Enums::ProjectPaymentFrequency, null: false
      field :rate_type, String, null: true
      field :starts_on, GraphQL::Types::ISO8601Date, null: true
      field :status, Enums::ProjectStatus, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

      def assigmnents
        object.assignments.include(:work_weeks)
      end

      delegate :users, to: :object

      def work_weeks(start_date: nil, end_date: nil)
        scope = object.work_weeks

        if start_date.present?
          scope = scope.where(year: start_date.year..).or(scope.where('cweek >= ? AND year >= ?', start_date.cweek, start_date.year))
        end

        if end_date.present?
          scope = scope.where(year: ..end_date.year).or(scope.where('cweek <= ? AND year <= ?', end_date.cweek, end_date.year))
        end

        scope
      end
    end
  end
end
