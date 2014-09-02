class UserInvitesController < ApplicationController
  skip_before_filter :check_current_company

  def index
    @invites = Invite.where(email: current_user.email)
  end

  def accept
    @invite = Invite.find(params[:invite_id]) if Invite.find(params[:invite_id]).email == current_user.email
    @invite.company.memberships.build(user: current_user, permissions: [])
    # why is the membership being persisted on a failed save?
    # save is failing because membership already exists?
    @invite.accept

    if @invite.save
      if current_user.current_company.blank?
        current_user.current_company = @invite.company
      end
      @invite.send_response_email(current_user)
      flash[:notice] = "Accepted invitation"
      redirect_to user_invites_path
    else
      flash[:notice] = "Something went wrong"
      redirect_to user_invites_path
    end
  end

  def decline
    @invite = Invite.find(params[:invite_id]) if Invite.find(params[:invite_id]).email == current_user.email
    @invite.decline
    if @invite.save
      @invite.send_response_email(current_user)
      flash[:notice] = "Declined invitation"
      redirect_to user_invites_path
    else
      flash[:notice] = "Something went wrong"
      redirect_to user_invites_path
    end
  end
end
