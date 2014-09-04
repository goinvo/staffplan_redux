class UserInvitesController < ApplicationController
  skip_before_filter :check_current_company

  def index
    @invites = Invite.where(email: current_user.email)
  end

  def accept
    @invite = Invite.find(params[:id]) if Invite.find(params[:id]).email == current_user.email
    @membership = @invite.company.memberships.build(user: current_user)
    @invite.accept

    Company.transaction do
      begin
        @invite.save
        @membership.save
        if current_user.current_company.blank?
          current_user.current_company = @invite.company
        end
        @invite.send_response_email(current_user)
        flash[:notice] = "Accepted invitation"
        redirect_to invites_path
      rescue
        flash[:notice] = "Something went wrong"
        redirect_to invites_path
      end
    end
  end

  def decline
    @invite = Invite.find(params[:id]) if Invite.find(params[:id]).email == current_user.email
    @invite.decline
    if @invite.save
      @invite.send_response_email(current_user)
      flash[:notice] = "Declined invitation"
      redirect_to invites_path
    else
      flash[:notice] = "Something went wrong"
      redirect_to invites_path
    end
  end
end
