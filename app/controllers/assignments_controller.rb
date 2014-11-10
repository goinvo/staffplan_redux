class AssignmentsController < ApplicationController

  respond_to :json

  before_filter :find_assignment, only: [:update, :destroy]

  def create
    find_or_initialize_client_by_name
    find_or_initialize_project_by_name

    @assignment = @project.assignments.build(assignment_params)
    @client.projects << @project
    @client.save

    respond_with(@assignment)
  end

  def update
    if @assignment.update(assignment_params)
      respond_with(@assignment)
    else
      flash.now[:notice] = "Couldn't update your assignment"
      render :edit
    end
  end

  def destroy
    # @assignment.destroy
    render(json: {message: "assignment-destroyed"})
  end

  private

  def assignment_params
    params.require(:assignment).permit(:user_id, :project_id, :assignment_archived, :assignment_proposed)
  end

  def client_params
    params.require(:assignment).permit(:client_name)
  end

  def project_params
    params.require(:assignment).permit(:project_name)
  end

  def find_assignment
    @assignment = current_user.current_company.assignments.find(params[:id])

    if @assignment.nil?
      render(:json => {error: "not-found"}, status: :not_found) and return
    end
  end

  def find_client_by_client_id
    @client = current_user.current_company.clients.where(id: params[:assignment][:client_id]).first
  end

  def find_client_by_client_name
    @client = current_user.current_company.clients.where(name: params[:assignment][:client_name]).first
  end

  def find_or_initialize_client_by_name
    # TODO: create a slug of client's name to use as a unique lookup.
    find_client_by_client_id

    if @client.nil?
      find_client_by_client_name
    end

    if @client.nil?
      @client = current_user.current_company.clients.build(name: client_params[:client_name])
    end
  end

  def find_project_by_project_id
    @project = current_user.current_company.projects.where(id: params[:assignment][:project_id]).first
  end

  def find_project_by_project_name
    @project = current_user.current_company.projects.where(name: params[:assignment][:project_name]).first
  end

  def find_or_initialize_project_by_name
    # TODO: create a slug of project's name to use as a unique lookup.
    find_project_by_project_id

    if @project.nil?
      find_project_by_project_name
    end

    if @project.nil?
      @project = current_user.current_company.projects.build(name: project_params[:project_name])
    end
  end
end
