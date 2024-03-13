module Mutations
  class UpsertProject < BaseMutation
    description "Create or update a project."

    # arguments passed to the `resolve` method
    argument :id, ID, required: false, description: "The ID of the project to update."
    argument :client_id, ID, required: false, description: "The ID of the client for this project."
    argument :name, String, required: false, description: "The name of the project."
    argument :status, String, required: false, description: "The status of the project."
    argument :cost, Float, required: false, description: "The cost of the project."
    argument :payment_frequency, String, required: false, description: "The frequency of payment for the project."
    argument :starts_on, GraphQL::Types::ISO8601Date, required: false, description: "The date this project starts."
    argument :ends_on, GraphQL::Types::ISO8601Date, required: false, description: "The date this project ends."

    # return type from the mutation
    type Types::StaffPlan::ProjectType, null: true

    def resolve(id: nil, client_id: nil, name: nil, status: nil, cost: nil, payment_frequency: nil, starts_on: nil, ends_on: nil)
      current_company = context[:current_company]

      # try and find the assignment
      project = if id.present?
        current_company.projects.find(id)
      end

      if project.blank?
        client = current_company.clients.find_by(id: client_id)

        # client must belong to the current company
        if client.nil?
          context.add_error(
            GraphQL::ExecutionError.new("Client not found", extensions: { attribute: "client_id" })
          )

          return {}
        end

        project = client.projects.new
      end

      project.assign_attributes(name:) if name.present?
      project.assign_attributes(status:) if status.present?
      project.assign_attributes(cost:) if cost.present?
      project.assign_attributes(payment_frequency:) if payment_frequency.present?
      project.assign_attributes(starts_on:) if starts_on.present?
      project.assign_attributes(ends_on:) if ends_on.present?

      if project.valid?
        project.save!
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