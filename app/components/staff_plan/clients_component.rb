# frozen_string_literal: true

module StaffPlan
  class ClientsComponent < ViewComponent::Base
    def initialize(user:, target_date:)
      @user = user
      @target_date = target_date
    end
    attr_reader :user, :target_date

    def user_assignments(client)
      user
        .assignments
        .includes(:project)
        .joins(:project)
        .where(project: { client_id: client.id })
        .where(project: { status: %w[confirmed unconfirmed] })
        .where.not(status: %w[archived completed cancelled])
        .order('project.name')
    end

    def visible_clients
      user.clients.distinct.order(:name)
    end
  end
end
