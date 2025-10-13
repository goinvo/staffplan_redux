# frozen_string_literal: true

module StaffPlan
  class ClientsComponent < ViewComponent::Base
    def initialize(user:, target_date:)
      @user = user
      @target_date = target_date
    end
    attr_reader :user, :target_date

    def visible_clients
      user.clients.distinct.order(:name)
    end

    def user_assignments(client)
      user.assignments.includes(:project).joins(:project).where(project: {status: ['confirmed', 'unconfirmed']}).where.not(status: ['archived', 'completed']).where(project: { client_id: client.id }).order('project.name')
    end
  end
end
