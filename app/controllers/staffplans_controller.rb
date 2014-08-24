class StaffplansController < ApplicationController
  def index
    @users = current_company.active_users.includes(:memberships, :staffplans_list_views).all
  end
end
