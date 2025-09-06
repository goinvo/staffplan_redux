# frozen_string_literal: true

module Types
  module StaffPlan
    class WorkWeeksInputObject < Types::BaseInputObject
      description 'Attributes for creating or updating a work week record for a StaffPlan user.'
      argument :actual_hours, Int, required: false, description: 'The actual hours for this work week.'
      argument :cweek, Int, required: true, description: 'The calendar week number of the work week.'
      argument :estimated_hours, Int, required: false, description: 'The estimated hours for this work week.'
      argument :year, Int, required: true, description: 'The calendar year of the work week.'
    end
  end
end
