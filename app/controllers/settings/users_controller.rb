class Settings::UsersController < ApplicationController
  before_action :require_user!
  before_action :require_company_owner_or_admin!

  def index
    @users = current_company.users.all
  end

  def show
    @user = current_company.users.find(params[:id])
  end

  def edit
    @user = current_company.users.find(params[:id])
  end

  def update
    @user = current_company.users.find(params[:id])

    if @user.update(edit_params)
      flash[:notice] = 'User updated successfully'
      redirect_to settings_user_path(@user)
    else
      render :edit
    end
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

  def edit_params
    params.require(:user).permit(:name, :role)
  end
end
