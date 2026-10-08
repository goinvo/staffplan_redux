# frozen_string_literal: true

class ProjectsController < RailsUiController
  def index; end

  def show
    @project = current_company.projects.find(params[:id])
  end
end
