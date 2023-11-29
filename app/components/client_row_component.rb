# frozen_string_literal: true

class ClientRowComponent < ViewComponent::Base
  def initialize(client:)
    @client = client
  end
end
