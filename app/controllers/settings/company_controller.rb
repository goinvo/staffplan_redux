class Settings::CompanyController < ApplicationController

  before_action :require_user!
  before_action :require_company_owner_or_admin!
  def show
  end

  def update
    # handle avatar changes first
    if update_params[:avatar].present?
      current_company.assign_attributes(avatar: update_params[:avatar])
      current_company.attachment_changes.any? && current_company.save
    end

    current_company.assign_attributes(update_params.except(:avatar))

    if current_company.save
      flash[:success] = "Updates saved!"
      redirect_to settings_path
    else
      flash.now[:error] = "Some information couldn't be saved."

      respond_to do |format|
        format.turbo_stream
        format.html { render :show }
      end
    end
  end

  private

  def update_params
    params.require(:company).permit(:name, :avatar)
  end
end
