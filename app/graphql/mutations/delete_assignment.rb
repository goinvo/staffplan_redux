module Mutations
  class DeleteAssignment < BaseMutation
    description "Delete an assignment."

    # arguments passed to the `resolve` method
    argument :assignment_id, ID, required: true,
             description: "The ID of the assignment to delete. Must be a TBD assignment."

    # return type from the mutation
    type Types::StaffPlan::AssignmentType

    def resolve(assignment_id:)
      assignment = context[:current_company].assignments.find(assignment_id)

      assignment.destroy

      if assignment.errors.any?
        assignment.errors.each do |error|
          context.add_error(
            GraphQL::ExecutionError.new(
              error.full_message,
              extensions: {
                attribute: error.attribute.to_s,
              }
            )
          )
        end
      end

      assignment
    end
  end
end
