class StaffPlans::WorkWeeksController < ApplicationController
  before_action :require_user!

  before_action :set_beginning_of_week
  def create
    @work_week = assignment.work_weeks.create(create_work_week_params)
  end

  def update
    @work_week = assignment.work_weeks.find(params[:id])
    @work_week.update(create_work_week_params)
  end

  private

  def set_beginning_of_week
    @beginning_of_week = params[:beginning_of_week].to_i
  end

  def create_work_week_params
    params.require(:work_week).permit(:estimated_hours, :actual_hours, :cweek, :year, :beginning_of_week)
  end

  def edit_work_week_params
    params.require(:work_week).permit(:estimated_hours, :actual_hours, :cweek, :year, :beginning_of_week)
  end

  def assignment
    current_user.assignments.find(params[:assignment_id])
  end
end
