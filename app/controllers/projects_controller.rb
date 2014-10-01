class ProjectsController < ApplicationController
  def index
    @projects = current_user.current_company.projects.order('name asc')
  end

  def show
    @client = current_user.current_company.clients.find(params[:client_id])
    @project = current_user.current_company.projects.find(params[:id])
  end

  def new
    @client = current_user.current_company.clients.find(params[:client_id])
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.company = current_user.current_company
    @project.client = current_user.current_company.clients.find(params[:client_id])

    if @project.save
      flash[:notice] = "The project was created successfully"
      redirect_to client_project_path(@project.client, @project)
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
      redirect_to client_project_path(@project.client, @project)
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
end
