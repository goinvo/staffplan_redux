# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :require_user!

  def create; end

  def edit
    @project = current_company.projects.find(params[:id])
  end

  def new; end

  def update
    @project = current_company.projects.find(params[:id])

    if @project.update(project_params)
      # Success - will render update.turbo_stream.erb if it exists
      render :edit
    else
      # Validation failed - re-render the form with errors
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def project_params
    params.expect(project: %i[name description hours starts_on ends_on])
  end
end
