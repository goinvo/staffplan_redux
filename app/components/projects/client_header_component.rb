# frozen_string_literal: true

module Projects
  class ClientHeaderComponent < ViewComponent::Base
    attr_reader :client, :name, :error

    def initialize(client:, name: client.name, error: nil)
      @client = client
      @name = name
      @error = error
    end
  end
end
