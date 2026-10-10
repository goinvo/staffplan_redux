# frozen_string_literal: true

module Projects
  class AddProjectRowComponent < ViewComponent::Base
    attr_reader :company, :new_project, :open

    def initialize(company:, new_project: NewProject.new, open: false)
      @company = company
      @new_project = new_project
      @open = open
    end

    def client_options
      company.clients.order(:name).map { { value: it.name } }
    end

    def error(attribute)
      new_project.errors[attribute].first
    end
  end
end
