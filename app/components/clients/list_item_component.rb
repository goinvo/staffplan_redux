# frozen_string_literal: true

module Clients
  class ListItemComponent < ViewComponent::Base
    def initialize(client:, current_company:)
      @current_company = current_company
      @client = client
    end

    def client_description
      @client.description
    end

    def client_name
      @client.name
    end

    def client_status
      @client.status
    end
  end
end
