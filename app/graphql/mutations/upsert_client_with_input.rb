# frozen_string_literal: true

module Mutations
  class UpsertClientWithInput < BaseMutation
    description 'Create or update a client.'

    argument :input, Types::ClientAttributes, required: true, description: 'Attributes for creating or updating a client.'

    # return type from the mutation
    type Types::StaffPlan::ClientType, null: true

    def resolve(input:)
      current_company = context[:current_company]

      # try and find the client
      client = if input.id.present?
                 current_company.clients.find(input.id)
               end

      if client.blank?
        client = current_company.clients.new
      end

      client.assign_attributes(input.to_h.slice(:name, :description, :status))

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
