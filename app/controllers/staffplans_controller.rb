class StaffplansController < ApplicationController
  def index
    @users = current_company.active_users.includes(:memberships, :staffplans_list_views).to_a
  end

  def show
    @user = current_company.users.find(params[:id])
    @user_projects = @user.user_projects.for_company(current_company).includes(:work_weeks, :assignment_totals).to_a
  end
end
