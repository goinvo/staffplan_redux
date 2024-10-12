class Users::ProfileController < ApplicationController
  before_action :require_user!
  def show
  end

  def update
    # handle avatar changes first
    if user_params[:avatar].present?
      current_user.assign_attributes(avatar: user_params[:avatar])
      current_user.attachment_changes.any? && current_user.save
    end

    current_user.assign_attributes(user_params.except(:avatar))

    if current_user.save
      flash[:success] = 'Your profile was updated successfully'
      redirect_to users_profile_path
    else
      flash.now[:error] = 'There was a problem updating your profile'

      respond_to do |format|
        format.turbo_stream
        format.html { render :show }
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :avatar)
  end
end
