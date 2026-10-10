# frozen_string_literal: true

class PeopleController < RailsUiController
  def index
    @window = Timeline::Window.from_param(params[:start])
    @sort = remembered_sort(Timeline::PeopleSort, :people_sort)
    @show_deactivated = params[:show_deactivated].present?

    memberships = current_company.memberships.includes(user: { avatar_attachment: :blob }).to_a
    @deactivated_count = memberships.count(&:inactive?)
    memberships.select!(&:active?) unless @show_deactivated
    @deactivated_ids = memberships.select(&:inactive?).map(&:user_id)

    users = memberships.map(&:user)
    assignments = Assignment.where(user: users, project: current_company.projects.where.not(status: Project::ARCHIVED))
    @people = @sort.apply(users, assignments:)
    @hours = Timeline::WeeklyHours.new(assignments:, window: @window)
    @assignments_by_user = @hours.assignments.group_by(&:user_id)
  end

  def show
    @user = current_company.users.find(params[:id])
    @window = Timeline::Window.from_param(params[:start])
    @sort = remembered_sort(Timeline::AssignmentSort, :my_staffplan_sort)
    @own_page = @user == current_user
    @show_hidden = @own_page && params[:show_hidden].present?

    shown, @hidden_assignments = assignments.partition(&:focused)
    @hidden_assignments = [] unless @own_page
    @assignments = @sort.apply(@show_hidden ? shown + @hidden_assignments : shown)
    @hours = Timeline::WeeklyHours.new(assignments: @assignments, window: @window)
    @hidden_hours = Timeline::WeeklyHours.new(assignments: @hidden_assignments, window: @window)
  end

  private

  def assignments
    @user.assignments
      .where(project: current_company.projects.where.not(status: Project::ARCHIVED))
      .includes(:work_weeks, project: :client)
  end

  def remembered_sort(sort_class, cookie)
    return sort_class.parse(cookies[cookie]) if params[:sort].blank?

    sort = sort_class.parse(params[:sort])
    cookies.permanent[cookie] = sort.to_param
    sort
  end
end
