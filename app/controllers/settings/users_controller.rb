class Settings::UsersController < ApplicationController
  before_action :require_user!
  before_action :require_company_owner_or_admin!

  def index
    @users = current_company.users.all
  end

  def show
  end

  def edit
  end

  def update
  end

  def new
  end

  def create
  end

  def destroy
  end
end
