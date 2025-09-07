# frozen_string_literal: true

class StaffplansController < ApplicationController
  before_action :require_user!

  layout 'staffplan'

  def index; end

  def show
    @user = current_company.users.find(params[:id])
  end
end
