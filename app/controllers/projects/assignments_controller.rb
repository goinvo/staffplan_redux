# frozen_string_literal: true

module Projects
  class AssignmentsController < RailsUiController
    def create
      project = current_company.projects.find(params[:project_id])
      assignment = project.assignments.create!(status: Assignment::PROPOSED)

      flash[:highlight] = assignment.id
      redirect_back_or_to project_path(project), status: :see_other
    end
  end
end
