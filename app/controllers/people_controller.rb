# frozen_string_literal: true

class PeopleController < RailsUiController
  def index; end

  def show
    @user = current_company.users.find(params[:id])
    @window = Timeline::Window.from_param(params[:start])
    @hours = Timeline::WeeklyHours.new(
      assignments: @user.assignments.where(project: current_company.projects),
      window: @window,
    )
  end
end
