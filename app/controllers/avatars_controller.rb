class AvatarsController < ApplicationController
  before_action :require_user!
  def destroy
    current_user.avatar.purge if current_user.avatar.attached?
    flash[:success] = "Custom avatar deleted successfully."
    redirect_to users_profile_path
  end
end
