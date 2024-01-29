class DashboardController < ApplicationController
  before_action :require_user!

  def show
  end

  def switch_account
    membership = current_user.memberships.active.find_by!(company_id: params[:company_id])
    current_user.update(current_company: membership.company)
    flash[:success] = "Current company has been changed."
    redirect_to root_path
  end
end
