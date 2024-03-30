class SettingsController < ApplicationController

  before_action :require_user!
  before_action :require_company_owner_or_admin!
  def show
  end

  def update
    if current_company.update(update_params)
      flash[:success] = "Company updated successfully"
      redirect_to settings_path
    else
      render :show
    end
  end

  private

  def update_params
    params.require(:company).permit(:name, :avatar)
  end
end
