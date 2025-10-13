class ProjectsController < ApplicationController
  before_action :require_user!

  def edit
    @project = current_company.projects.find(params[:id])

    respond_to do |format|
      format.html # Regular HTML response
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("modal-container",
          StaffPlan::ModalComponent.new(title: "Edit Project", show: true) do
            render partial: "form", locals: { project: @project }
          end
        )
      end
    end

  end

  def update
  end

  def new
  end

  def create
  end
end
