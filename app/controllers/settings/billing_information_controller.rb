# frozen_string_literal: true

module Settings
  class BillingInformationController < ApplicationController
    before_action :require_user!
    before_action :require_company_owner_or_admin!

    def edit; end

    def show; end

    def update; end
  end
end
