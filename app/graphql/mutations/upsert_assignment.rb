module Mutations
  class UpsertAssignment < BaseMutation
    description "Create or update an assignment."

    # arguments passed to the `resolve` method
    argument :id, ID, required: false,
             description: "The ID of the assignment to update."
    argument :project_id, ID, required: true,
             description: "The ID of the project this assignment is being created for."
    argument :user_id, ID, required: false,
             description: "The ID of the user being assigned to the project. If omitted, the assignment status cannot be 'active'."
    argument :status, String, required: true,
             description: "The status of the assignment."
    argument :focused, Boolean, required: false,
              description: "Should this assignment be rendered by default on the assignee's StaffPlan. Can only be updated by the assignee."
    argument :estimated_weekly_hours, Integer, required: false,
             description: "The estimated weekly hours for this assignment."
    argument :starts_on, GraphQL::Types::ISO8601Date, required: false,
             description: "The date this assignment starts."
    argument :ends_on, GraphQL::Types::ISO8601Date, required: false,
             description: "The date this assignment ends."

    # return type from the mutation
    type Types::StaffPlan::AssignmentType

    def resolve(id: nil, project_id:, user_id: nil, status:, focused: nil, estimated_weekly_hours: nil, starts_on: nil, ends_on: nil)
      current_company = context[:current_company]
      current_user = context[:current_user]

      # try and find the assignment
      assignment = if id.present?
        current_company.assignments.find(id)
      end

      if assignment
        assignment.assign_attributes(project_id:, user_id:, status:)
      else
        project = current_company.projects.find(project_id)
        assignment = project.assignments.new(user_id:, status:)
      end

      assignment.assign_attributes(focused:) if !focused.nil? && current_user == assignment.user
      assignment.assign_attributes(estimated_weekly_hours: estimated_weekly_hours) if estimated_weekly_hours
      assignment.assign_attributes(starts_on: starts_on) if starts_on
      assignment.assign_attributes(ends_on: ends_on) if ends_on

      if assignment.valid?
        assignment.save!
      else
        assignment.errors.group_by_attribute.each do |attribute, errors|
          errors.each do |error|
            context.add_error(
              GraphQL::ExecutionError.new(
                error.full_message,
                extensions: {
                  attribute: attribute.to_s,
                }
              )
            )
          end
        end
      end

      assignment
    end
  end
end
