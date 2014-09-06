class CurrentCompaniesController < ApplicationController

  def update
    current_user.current_company = current_user.companies.find(current_company_params)

    redirect_to staffplans_path
  end

  private

  def current_company_params
    params.require(:id)
  end
end
