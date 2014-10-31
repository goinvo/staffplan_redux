class WorkWeeksController < ApplicationController

  respond_to :json

  before_filter :find_assignment

  def create
    @work_week = @assignment.work_weeks.create(create_params)
    respond_with(@work_week)
  end

  def update
    @work_week = @assignment.work_weeks.where(id: params[:id]).first

    if @work_week.nil?
      render(:json => {error: "not-found"}, status: :not_found) and return
    else
      @work_week.update_attributes(update_params)
      respond_with(@work_week)
    end
  end

  private

  def find_assignment
    @assignment = current_user.current_company.assignments.where(id: params[:assignment_id]).first

    if @assignment.nil?
      render(:json => {error: "not-found"}, status: :not_found) and return
    end
  end

  def create_params
    params.permit(:cweek, :year, :actual_hours, :estimated_hours, :beginning_of_week)
  end

  def update_params
    params.permit(:actual_hours, :estimated_hours)
  end
end
