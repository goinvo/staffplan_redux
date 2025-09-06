# frozen_string_literal: true

module StaffPlan
  class AssignmentComponent < ViewComponent::Base
    def initialize(user:, assignment:, index:)
      @user = user
      @assignment = assignment
      @index = index
    end
    attr_reader :user, :assignment, :index

    def client_name
      return '' if index.positive?

      assignment.client.name
    end
  end
end
