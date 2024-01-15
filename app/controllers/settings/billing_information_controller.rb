class Settings::BillingInformationController < ApplicationController
  before_action :require_user!
  before_action :require_company_owner_or_admin!
  def show
  end

  def edit
  end

  def update
  end
end
