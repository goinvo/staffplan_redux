class CompaniesController < ApplicationController
  skip_before_filter :check_current_company

  def index
    @companies = current_user.companies
  end

  def show
    @company = current_user.companies.find(params[:id])
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)

    if @company.save
      flash[:notice] = "Your company was created successfully"
      redirect_to companies_path
    else
      flash.now[:notice] = "Couldn't create your company"
      render :new
    end
  end

  def edit
    @company = current_user.companies.find(params[:id])
  end

  def update
    @company = current_user.companies.find(params[:id])

    if @company.update(company_params)
      flash[:notice] = "Your company was updated successfully"
      redirect_to company_path(@company)
    else
      flash.now[:notice] = "Couldn't update your company"
      render :edit
    end
  end

  def destroy
    @company = current_user.companies.find(params[:id])
    @company.destroy
    flash[:notice] = "Your company was deleted"
    redirect_to companies_path
  end

  private

  def company_params
    params.require(:company).permit(:name)
  end
end
