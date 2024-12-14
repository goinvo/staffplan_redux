module Mutations
  class DeleteProject < BaseMutation
    description "Delete a project."

    # arguments passed to the `resolve` method
    argument :project_id, ID, required: true,
             description: "The ID of the project to delete. The project must meet the delete-ability requirements: no assignments, or all assignments having no actual hours recorded."

    # return type from the mutation
    type Types::StaffPlan::ProjectType

    def resolve(project_id:)
      project = context[:current_company].projects.find(project_id)

      project.destroy

      if project.errors.any?
        project.errors.each do |error|
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

      project
    end
  end
end
