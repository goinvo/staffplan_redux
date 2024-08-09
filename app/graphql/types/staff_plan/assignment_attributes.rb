class Types::StaffPlan::AssignmentAttributes < Types::BaseInputObject
  description "Attributes for creating an assignment"

  argument :user_id, ID, required: false, description: "The user assigned to this assignment"
  argument :project_id, ID, required: false, description: "The project this assignment is for"
  argument :status, String, required: false, description: "The status of the assignment"
  argument :starts_on, GraphQL::Types::ISO8601Date, required: false, description: "The date the assignment starts"
  argument :ends_on, GraphQL::Types::ISO8601Date, required: false, description: "The date the assignment ends"
  argument :estimated_weekly_hours, Integer, required: false, description: "The estimated weekly hours for this assignment"
end