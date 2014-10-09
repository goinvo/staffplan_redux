class MembershipStateManagementController < ApplicationController
  before_filter :set_company
  before_filter :check_if_disabled
  before_filter :authorized_for_admin_tools

  def index
    @company = current_company
    @memberships = @company.memberships.sort_by {|m| [m.aasm_state, m.user.last_name] }
  end

  def activate
    @membership = current_company.memberships.find(membership_state_params)
    @membership.activate

    if @membership.save
      flash[:notice] = "User now active"
      redirect_to memberships_path
    else
      flash[:notice] = "Can't activate user"
      redirect_to memberships_path
    end
  end

  def disable
    @membership = current_company.memberships.find(membership_state_params)
    @membership.disable

    if @membership.save
      flash[:notice] = "User disabled"
      redirect_to memberships_path
    else
      flash[:notice] = "Can't disable user"
      redirect_to memberships_path
    end
  end

  def archive
    @membership = current_company.memberships.find(membership_state_params)
    @membership.archive

    if @membership.save
      flash[:notice] = "User archived"
      redirect_to memberships_path
    else
      flash[:notice] = "Can't archive user"
      redirect_to memberships_path
    end
  end

  private

  def membership_state_params
    params.require(:id)
  end

  def current_company
    current_user.current_company
  end

  def set_company
    @company = current_company
  end
end
