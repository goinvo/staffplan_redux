# frozen_string_literal: true

class StaffplansController < ApplicationController
  before_action :require_user!

  layout 'staffplan'

  def index; end

  def show
    @target_date = params[:ts] ? Time.zone.at(params[:ts].to_i).to_date : Time.zone.today
    @user = current_company.users.find(params[:id])
  end
end
