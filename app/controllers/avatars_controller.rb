class AvatarsController < ApplicationController
  def destroy
    current_user.avatar.purge
    flash[:success] = "Custom avatar deleted successfully. Gravatar will be used."
    redirect_to users_profile_path
  end
end
