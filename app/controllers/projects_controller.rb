# frozen_string_literal: true

class ProjectsController < RailsUiController
  def create
    @new_project = NewProject.new(company: current_company, user: (current_user unless add_row?), **params.expect(new_project: %i[project_name client_name hours starts_on ends_on]))

    if !@new_project.save
      render turbo_stream: invalid_form_stream, status: :unprocessable_content
    elsif add_row?
      flash[:highlight] = @new_project.project.id
      redirect_back_or_to projects_path, status: :see_other
    else
      redirect_to project_path(@new_project.project), status: :see_other
    end
  end

  def index
    @client = current_company.clients.find_by(id: params[:client]) if params[:client].present?
    return redirect_to(projects_path) if params[:client].present? && @client.nil?

    @window = Timeline::Window.from_param(params[:start])
    @sort = remembered_sort(Timeline::ProjectSort, :projects_sort)
    @show_archived = params[:show_archived].present?

    projects = (@client || current_company).projects.includes(:client).to_a
    @archived_count = projects.count(&:archived?)
    projects.reject!(&:archived?) unless @show_archived

    @projects = @sort.apply(projects)
    @hours = Timeline::WeeklyHours.new(assignments: Assignment.where(project: @projects), window: @window)
    @assignments_by_project = @hours.assignments.group_by(&:project_id)
    @summaries = Timeline::ProjectSummary.for(@projects)
  end

  def new
    @new_project = NewProject.new
  end

  def show
    @project = current_company.projects.find(params[:id])
  end

  private

  def add_row?
    params[:form] == 'add_project'
  end

  def invalid_form_stream
    if add_row?
      turbo_stream.replace('add_project', Projects::AddProjectRowComponent.new(company: current_company, new_project: @new_project, open: true))
    else
      frame = params[:form] == 'first_project' ? 'first_project' : 'new_project'
      turbo_stream.update(frame, partial: 'projects/form', locals: { new_project: @new_project, frame: })
    end
  end
end
