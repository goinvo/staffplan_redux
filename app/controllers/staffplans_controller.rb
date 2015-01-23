class StaffplansController < ApplicationController
  def index
    @users = current_company.active_users.map(&:decorate)
  end

  def show
    @user = current_company.users.find(params[:id])
    @user_projects = @user.user_projects.for_company(current_company).includes(:work_weeks, :assignment_totals).to_a
  end

  def date_range
    @users = current_company.active_users.includes(:memberships, :staffplans_list_views).to_a
    render(json: ActiveModel::ArraySerializer.new(@users, each_serializer: StaffplansIndexUserSerializer, from: params[:from], to: params[:to], count: params[:count]))
  end
end
