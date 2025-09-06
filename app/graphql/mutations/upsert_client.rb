# frozen_string_literal: true

module Mutations
  class UpsertClient < BaseMutation
    description 'Create or update a client.'

    # arguments passed to the `resolve` method
    argument :description, String, required: false, description: "The client's description."
    argument :id, ID, required: false, description: 'The ID of the client to update.'
    argument :name, String, required: false, description: 'The name of the client.'
    argument :status, String, required: false, description: 'The status of the client.'

    # return type from the mutation
    type Types::StaffPlan::ClientType, null: true

    def resolve(id: nil, name: nil, description: nil, status: nil)
      current_company = context[:current_company]

      # try and find the client
      client = if id.present?
                 current_company.clients.find(id)
               end

      if client.blank?
        client = current_company.clients.new
      end

      client.assign_attributes(name: name) if name.present?
      client.assign_attributes(description: description) if description.present?
      client.assign_attributes(status: status) if status.present?

      if client.valid?
        client.save!
      else
        client.errors.group_by_attribute.each do |attribute, errors|
          errors.each do |error|
            context.add_error(
              GraphQL::ExecutionError.new(
                error.full_message,
                extensions: {
                  attribute: attribute.to_s,
                },
              ),
            )
          end
        end
      end

      client
    end
  end
end
