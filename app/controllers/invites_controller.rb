class InvitesController < ApplicationController
  before_filter :set_company
  before_filter :authorized_for_admin_tools

  def index
    @invites = current_company.invites
  end

  def new
    @invite = Invite.new
  end

  def create
    @invite = current_company.invites.build(invite_params)
    @invite.sender = current_user

    if @invite.save
      @invite.email_invitation
      flash[:notice] = "Your invitation was successfully sent"
      redirect_to company_invites_path(@invite.company)
    else
      flash.now[:notice] = "Couldn't send your invitation"
      render :new
    end
  end

  def destroy
    @invite = current_company.invites.find(params[:id])

    @invite.destroy
    flash[:notice] = "Invitation deleted"
    redirect_to company_invites_path(current_company)
  end

  private

  def invite_params
    params.require(:invite).permit(:email)
  end

  def current_company
    current_user.current_company
  end

  def set_company
    @company = current_company
  end
end
