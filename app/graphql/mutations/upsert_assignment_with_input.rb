module Mutations
  class UpsertAssignmentWithInput < BaseMutation
    description "Create or update an assignment."

    argument :input, Types::AssignmentAttributes, required: true, description: "Attributes for creating or updating an assignment."

    # return type from the mutation
    type Types::StaffPlan::AssignmentType

    def resolve(input:)
      current_company = context[:current_company]

      # try and find the assignment
      assignment = if input.id.present?
        current_company.assignments.find(input.id)
      end

      if assignment
        assignment.assign_attributes(input.to_h.slice(:project_id, :user_id, :status))
      else
        project = current_company.projects.find(input.project_id)
        assignment = project.assignments.new(input.to_h.slice(:user_id, :status))
      end

      assignment.assign_attributes(input.to_h.slice(:estimated_weekly_hours, :starts_on, :ends_on))

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
