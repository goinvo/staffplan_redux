class StaffPlan::UsersController < ApplicationController

  def show
    @viewing_user = params[:id].blank? ? current_user : current_company.users.find(params[:id])
    @query = Queries::UserStaffPlan.new(user: @viewing_user, company: current_company)
  end
end
