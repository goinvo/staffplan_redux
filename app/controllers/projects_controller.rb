# frozen_string_literal: true

class ProjectsController < RailsUiController
  def create
    @new_project = ProjectForm.new(company: current_company, user: (current_user unless add_row?), **params.expect(new_project: %i[project_name client_name hours starts_on ends_on]))

    if !@new_project.save
      render turbo_stream: invalid_form_stream, status: :unprocessable_content
    elsif add_row?
      flash[:highlight] = @new_project.project.id
      redirect_back_or_to projects_path, status: :see_other
    else
      redirect_to project_path(@new_project.project), status: :see_other
    end
  end

  def edit
    @form = ProjectForm.for(current_company.projects.find(params[:id]))
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
    @new_project = ProjectForm.new
  end

  def show
    @project = current_company.projects.includes(:client).find(params[:id])
    @window = Timeline::Window.from_param(params[:start])
    @sort = remembered_sort(Timeline::StaffSort, :project_sort)

    memberships = current_company.memberships.to_a
    @inactive_user_ids = memberships.select(&:inactive?).map(&:user_id)
    @assignments = @sort.apply(@project.assignments.includes(:work_weeks, user: { avatar_attachment: :blob }))
    @available_users = User.where(id: memberships.select(&:active?).map(&:user_id) - @assignments.map(&:user_id)).order(:name)
    @hours = Timeline::WeeklyHours.new(assignments: @assignments, window: @window)
    @summary = Timeline::ProjectSummary.for([@project]).fetch(@project.id)
  end

  def update
    project = current_company.projects.find(params[:id])
    form = ProjectForm.for(project)
    form.assign_attributes(params.expect(project: %i[project_name client_name hours starts_on ends_on archived]))

    if form.save
      redirect_back_or_to project_path(project), status: :see_other
    elsif params[:form] == 'new_project'
      render turbo_stream: turbo_stream.update('new_project', partial: 'projects/form', locals: { new_project: form }), status: :unprocessable_content
    else
      render turbo_stream: turbo_stream.replace('project_header', Projects::ProjectHeaderComponent.new(project:, form:)), status: :unprocessable_content
    end
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
