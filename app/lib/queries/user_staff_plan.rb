module Queries
  class UserStaffPlan
    attr_reader :user, :company

    def initialize(user:, company:)
      raise ArgumentError, "user must be a User" unless user.is_a?(User)
      raise ArgumentError, "company must be a Company" unless company.is_a?(Company)

      @user = user
      @company = company
      @assignments = user.
        assignments.
        where(project: company.projects.active).
        includes(:work_weeks, project: :client).
        order('clients.name')
    end

    def work_weeks
      @work_weeks ||= @assignments.flat_map(&:work_weeks)
    end

    def clients
      @clients ||= @assignments.flat_map(&:project).map(&:client).uniq
    end

    def projects_for(client:)
      @assignments.map { |assignment| assignment.project if assignment.project.client == client }.compact
    end
  end
end