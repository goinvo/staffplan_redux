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

    if @user.memberships.find_by(company: current_company).update(role: params[:user][:role])
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

      respond_to do |format|
        format.html { render :new }
        format.turbo_stream
      end
    end
  end

  def toggle_status
    @user = current_company.users.find(params[:id])

    if @user == current_user
      flash[:error] = 'You cannot deactivate yourself'
      redirect_to settings_user_path(@user)
    else
      @user.toggle_status!(company: current_company)
      flash[:notice] = 'User status updated successfully. StaffPlan subscription should be updated within 5 minutes.'
      redirect_to settings_user_path(@user)
    end
  end

  private

  def create_params
    params.require(:user).permit(:email, :name, :role)
  end
end
