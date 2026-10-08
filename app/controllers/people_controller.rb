# frozen_string_literal: true

class PeopleController < RailsUiController
  SORT_COOKIE = :my_staffplan_sort

  def index; end

  def show
    @user = current_company.users.find(params[:id])
    @window = Timeline::Window.from_param(params[:start])
    @sort = assignment_sort
    @own_page = @user == current_user
    @show_hidden = @own_page && params[:show_hidden].present?

    shown, @hidden_assignments = assignments.partition(&:focused)
    @hidden_assignments = [] unless @own_page
    @assignments = @sort.apply(@show_hidden ? shown + @hidden_assignments : shown)
    @hours = Timeline::WeeklyHours.new(assignments: @assignments, window: @window)
    @hidden_hours = Timeline::WeeklyHours.new(assignments: @hidden_assignments, window: @window)
  end

  private

  def assignment_sort
    return Timeline::AssignmentSort.parse(cookies[SORT_COOKIE]) if params[:sort].blank?

    sort = Timeline::AssignmentSort.parse(params[:sort])
    cookies.permanent[SORT_COOKIE] = sort.to_param
    sort
  end

  def assignments
    @user.assignments
      .where(project: current_company.projects.where.not(status: Project::ARCHIVED))
      .includes(:work_weeks, project: :client)
  end
end
