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
    @user = User.new
  end

  def create
    begin
      @command = AddUserToCompany.new(
          email: create_params[:email],
          name: create_params[:name],
          role: create_params[:role],
          company: current_company
      )

      @command.call

      flash[:notice] = 'User added successfully'
      redirect_to settings_users_path
    rescue ActiveRecord::RecordInvalid
      @user = @command.user
      @user.valid?
      render :new
    end
  end

  def destroy
  end

  private

  def create_params
    params.require(:user).permit(:email, :name, :role)
  end
end
