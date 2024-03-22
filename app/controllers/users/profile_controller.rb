class Users::ProfileController < ApplicationController
  before_action :require_user!
  def show
  end

  def update
    if current_user.update(user_params)
      flash[:notice] = 'Your profile was updated successfully'
      redirect_to users_profile_path
    else
      render :show
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :avatar)
  end
end
