# frozen_string_literal: true

class ProjectsController < RailsUiController
  def create
    @new_project = NewProject.new(company: current_company, user: current_user, **params.expect(new_project: %i[project_name client_name hours starts_on ends_on]))

    if @new_project.save
      redirect_to project_path(@new_project.project), status: :see_other
    else
      render turbo_stream: turbo_stream.update('new_project', partial: 'projects/form', locals: { new_project: @new_project }), status: :unprocessable_content
    end
  end

  def index; end

  def new
    @new_project = NewProject.new
  end

  def show
    @project = current_company.projects.find(params[:id])
  end
end
