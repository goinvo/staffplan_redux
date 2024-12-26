module Mutations
  class UpsertProjectWithInput < BaseMutation
    description "Create or update a project."

    argument :input, Types::ProjectAttributes, required: true

    # return type from the mutation
    type Types::StaffPlan::ProjectType, null: true

    def resolve(input:)
      current_company = context[:current_company]

      # try and find the assignment
      id = input.dig(:id)
      project = if id.present?
        current_company.projects.find(id)
      end

      if project.blank?
        client = current_company.clients.find_by(id: input.dig(:client_id))

        # client must belong to the current company
        if client.nil?
          context.add_error(
            GraphQL::ExecutionError.new("Client not found", extensions: { attribute: "client_id" })
          )

          return {}
        end

        project = client.projects.new
      end

      project.assign_attributes(
        input.to_h.slice(:name, :status, :cost, :payment_frequency, :fte, :hours, :rate_type, :hourly_rate, :starts_on, :ends_on)
      )

      if project.valid?
        project.save!

        Array(input.assignments).map do |assignment|
          project.assignments << Assignment.new(assignment.to_h)
        end
      else
        project.errors.group_by_attribute.each do |attribute, errors|
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

      project
    end
  end
end
