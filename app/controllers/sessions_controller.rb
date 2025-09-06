# frozen_string_literal: true

class SessionsController < Passwordless::SessionsController
  before_action :redirect_to_dashboard_if_authenticated, only: %i[new]
  before_action :require_params, only: :create

  private

  def my_staffplan_url(current_user)
    if Prefab.enabled('rails-views')
      staffplan_path(current_user)
    else
      case Rails.env
      when :production
        "https://ui.staffplan.com/people/#{current_user.id}"
      else
        "http://localhost:8080/people/#{current_user.id}"
      end
    end
  end

  def redirect_to_dashboardRunninb_if_authenticated
    if current_user.present?
      redirect_to my_staffplan_url(current_user), allow_other_host: true
    end
  end

  def require_params
    if params[:passwordless].blank?
      redirect_to auth_sign_in_url, alert: 'Sorry, please try that again.' # rubocop:disable Rails/I18nLocaleTexts
    end
  end
  helper_method :my_staffplan_url
end
