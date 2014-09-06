class StaffplansController < ApplicationController
  def index
    @users = current_company.active_users.includes(:memberships, :staffplans_list_views).to_a
  end

  def show
    @user = current_company.users.includes(:staffplans_list_views).find(params[:id])
    @user_projects = @user.user_projects.active.includes(:work_weeks, :assignment_totals).to_a
  end
end
