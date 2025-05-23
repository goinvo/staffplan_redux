class Types::AssignmentAttributes < Types::BaseInputObject
  description "Attributes for creating or updating an assignment"
  argument :id, ID, required: false,
    description: "The ID of the assignment to update."
  argument :user_id, ID, required: false,
    description: "The ID of the user being assigned to the project. If omitted, the assignment status cannot be 'active'."
  argument :project_id, ID, required: false,
    description: "The project this assignment is for"
  argument :status, String, required: true,
    description: "The status of the assignment."
  argument :starts_on, GraphQL::Types::ISO8601Date, required: false,
    description: "The date the assignment starts"
  argument :ends_on, GraphQL::Types::ISO8601Date, required: false,
    description: "The date the assignment ends"
  argument :estimated_weekly_hours, Integer, required: false,
    description: "The estimated weekly hours for this assignment"
end
