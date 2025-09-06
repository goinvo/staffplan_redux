# frozen_string_literal: true

module Settings
  class UsersController < ApplicationController
    before_action :require_user!
    before_action :require_company_owner_or_admin!

    def create
      @command = AddUserToCompany.new(
        email: create_params[:email],
        name: create_params[:name],
        role: create_params[:role],
        company: current_company,
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

    def edit
      @user = current_company.users.find(params[:id])
    end

    def index
      @users = current_company.users.all
    end

    def new
      @user = User.new
    end

    def show
      @user = current_company.users.find(params[:id])
    end

    def toggle_status
      @user = current_company.users.find(params[:id])

      if @user == current_user
        flash[:error] = 'You cannot deactivate yourself'
      else
        @user.toggle_status!(company: current_company)
        flash[:notice] = 'User status updated successfully. StaffPlan subscription should be updated within 5 minutes.'
      end
      redirect_to settings_user_path(@user)
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

    private

    def create_params
      params.expect(user: %i[email name role])
    end
  end
end
