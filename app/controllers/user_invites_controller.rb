class UserInvitesController < ApplicationController
  skip_before_filter :check_current_company

  def index
    @invites = Invite.where(email: current_user.email)
  end

  def update
    @invite = Invite.find(params[:id]) if Invite.find(params[:id]).email == current_user.email
    @invite.accept

    if @invite.save
      @invite.company.memberships.build(company: @invite.company, user: current_user, permissions: [])
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

  def destroy
    @invite = Invite.find(params[:id]) if Invite.find(params[:id]).email == current_user.email
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
