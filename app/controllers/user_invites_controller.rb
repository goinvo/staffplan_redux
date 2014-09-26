class UserInvitesController < ApplicationController
  skip_before_filter :check_current_company

  def index
    @invites = current_user.pending_invites
  end

  def accept
    @invite = current_user.pending_invites.find(params[:id])
    @membership = @invite.company.memberships.build(user: current_user)
    @invite.accept

    Invite.transaction do
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
    @invite = current_user.pending_invites.find(params[:id])
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
