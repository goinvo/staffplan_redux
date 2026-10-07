# frozen_string_literal: true

class SessionsController < Passwordless::SessionsController
  before_action :redirect_to_dashboard_if_authenticated, only: %i[new]
  before_action :require_params, only: :create

  private

  def redirect_to_dashboard_if_authenticated
    if current_user.present?
      redirect_to my_staffplan_url, allow_other_host: true
    end
  end

  def require_params
    if params[:passwordless].blank?
      redirect_to auth_sign_in_url, alert: 'Sorry, please try that again.' # rubocop:disable Rails/I18nLocaleTexts
    end
  end
end
