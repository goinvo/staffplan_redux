class ProjectsController < ApplicationController
  def index
    @projects = current_user.current_company.projects
  end

  def show
    @project = current_user.current_company.projects.find(params[:id])
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      flash[:notice] = "The project was created successfully"
      redirect_to project_path(@project)
    else
      flash.now[:notice] = "Couldn't create the project"
      render :new
    end
  end

  def edit
    @project = current_user.current_company.projects.find(params[:id])
  end

  def update
    @project = current_user.current_company.projects.find(params[:id])

    if @project.update(project_params)
      flash[:notice] = "The project was updated successfully"
      redirect_to project_path(@project)
    else
      flash.now[:notice] = "Couldn't update the project"
      render :edit
    end
  end

  def destroy
    @project = current_user.current_company.projects.find(params[:id])

    @project.destroy
    flash[:notice] = "The project was deleted"
    redirect_to projects_path
  end

  private

  def project_params
    params.require(:project).permit(:client_id, :name, :proposed, :cost, :payment_frequency)
end
