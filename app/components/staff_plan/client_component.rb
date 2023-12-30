# frozen_string_literal: true

module StaffPlan
  class ClientComponent < ViewComponent::Base
    def initialize(client:, query:)
      @client = client
      @query = query
    end
  end
end