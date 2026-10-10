# frozen_string_literal: true

module People
  class AddProjectRowComponent < ViewComponent::Base
    attr_reader :user, :company, :proposal, :open

    def initialize(user:, company:, proposal: ProposedAssignment.new, open: false)
      @user = user
      @company = company
      @proposal = proposal
      @open = open
    end

    def client_options
      company.clients.order(:name).map { { value: it.name } }
    end

    def error(attribute)
      proposal.errors[attribute].first
    end

    def project_options
      company.projects.where.not(id: user.assignments.select(:project_id)).includes(:client).order(:name).map do |project|
        { value: project.name, group: project.client.name.strip, badge: ('archived' if project.archived?) }
      end
    end
  end
end
