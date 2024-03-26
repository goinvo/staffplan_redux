class ProjectsController < ApplicationController
  before_action :require_user!
  before_action :set_project, only: %i[ show edit update ]

  def index
    @projects = Project.includes(:company). all
  end

  def show
  end

  def new
    @client = Client.find_by(id: params[:client_id]) # optional
    @project = Project.new(
      client_id: params[:client_id],

      # TODO: make these configurable?
      status: Project::UNCONFIRMED,
      payment_frequency: Project::MONTHLY
    )
  end

  def edit
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to project_url(@project), notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @project.update(project_params)
      redirect_to project_url(@project), notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.require(:project).permit(:client_id, :name, :status, :cost, :payment_frequency)
    end
end
