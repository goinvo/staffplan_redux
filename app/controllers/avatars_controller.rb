# frozen_string_literal: true

class AvatarsController < ApplicationController
  before_action :require_user!
  before_action :find_attachable
  def destroy
    @attachable.avatar.purge if @attachable.avatar.attached?
    flash[:success] = 'Custom avatar deleted successfully.'
    redirect_to attachable_params[:redirect_to] || root_path
  end

  private

  def attachable_params
    params.expect(attachable: %i[type id redirect_to])
  end

  # TODO: extract this to a command object
  def find_attachable
    unless %w[User Company Client].include?(attachable_params[:type])
      flash[:error] = 'No attachment found.'
    end

    attachable = attachable_params[:type].constantize.find(attachable_params[:id])

    case attachable_params[:type]
    when 'User'
      # only users change their avatar
      if attachable == current_user
        @attachable = current_user
      else
        flash[:error] = "Sorry, you can't remove that attachment."
        redirect_to attachable_params[:redirect_to] || root_path and return
      end
    when 'Company'
      # admins and owners can change the current company's avatar
      if attachable == current_company &&
          current_company.admin_or_owner?(user: current_user)
        @attachable = current_company
      else
        flash[:error] = "Sorry, you can't remove that attachment."
        redirect_to attachable_params[:redirect_to] || root_path and return
      end
    when 'Client'
      # anyone can change a client's avatar
      @attachable = current_company.clients.find(attachable_params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Sorry, you can't remove that attachment."
    redirect_to attachable_params[:redirect_to] || root_path
  end
end
