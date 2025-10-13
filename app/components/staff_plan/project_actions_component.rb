# frozen_string_literal: true

module StaffPlan
  class ProjectActionsComponent < ViewComponent::Base
    def initialize(assignment:)
      @assignment = assignment
    end
    attr_reader :assignment
  end
end
