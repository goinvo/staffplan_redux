# frozen_string_literal: true

class ClientsController < RailsUiController
  def update
    client = current_company.clients.find(params[:id])
    name = params.expect(client: [:name])[:name].to_s.strip
    error = name_error(client, name)

    if error.nil? && client.update(name:)
      redirect_to projects_path(client: client.id), status: :see_other
    else
      client.restore_attributes
      header = Projects::ClientHeaderComponent.new(client:, name:, error: error || client.errors.full_messages.to_sentence)
      render turbo_stream: turbo_stream.replace('client_header', header), status: :unprocessable_content
    end
  end

  private

  def name_error(client, name)
    if name.blank?
      'Client is required'
    elsif current_company.clients.named(name).where.not(id: client.id).exists?
      'This client name is already taken. Please enter a different name.'
    end
  end
end
