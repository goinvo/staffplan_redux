module Queries
  class UserStaffPlan
    attr_reader :user, :company, :beginning_of_week

    def initialize(user:, company:, beginning_of_week: Date.today.beginning_of_week)
      raise ArgumentError, "user must be a User" unless user.is_a?(User)
      raise ArgumentError, "company must be a Company" unless company.is_a?(Company)

      @user = user
      @company = company
      @beginning_of_week = beginning_of_week.to_datetime.to_i
      @assignments = user.
        assignments.
        where(project: company.projects.active).
        includes(:work_weeks, project: :client).
        order('clients.name')
    end

    def assignment_for(project:)
      @assignments.find { |assignment| assignment.project == project }
    end

    def work_weeks
      @work_weeks ||= @assignments.flat_map(&:work_weeks)
    end

    def work_weeks_for(project:)
      work_weeks.select { |work_week| work_week.project == project }
    end

    def clients
      @clients ||= @assignments.flat_map(&:project).map(&:client).uniq
    end

    def projects_for(client:)
      @assignments.map { |assignment| assignment.project if assignment.project.client == client }.compact
    end
  end
end