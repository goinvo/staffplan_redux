class StaffPlans::UsersController < ApplicationController
  before_action :require_user!

  before_action :redirect_to_user_id, only: [:show]

  def show
    @viewing_user = current_company.users.find(params[:id])
    @beginning_of_week = beginning_of_week.at_beginning_of_day.to_i
    @query = Queries::UserStaffPlan.new(
      user: @viewing_user,
      company: current_company,
      beginning_of_week: beginning_of_week
    )
  end

  private

  def beginning_of_week
    date = if params[:beginning_of_week].present?
             Time.at(params[:beginning_of_week].to_i).to_date
           else
             Date.today
           end
    date.beginning_of_week
  end

  def redirect_to_user_id
    redirect_to staff_plans_user_url(current_user) if params[:id].blank?
  end
end
