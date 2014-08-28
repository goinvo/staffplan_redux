class InvitesController < ApplicationController
  def index
    @invites = current_company.invites
  end

  def new
    @company = current_company
    @invite = Invite.new
  end

  def create
    @company = current_company
    @invite = Invite.new(invite_params)
    @invite.sender = current_user
    @invite.company = @company

    if @invite.save
      @invite.email_invitation(current_user)
      flash[:notice] = "Your invitation was successfully sent"
      redirect_to company_invites_path(@company)
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
end
