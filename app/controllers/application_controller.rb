# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Passwordless::ControllerHelpers

  before_action :check_subscription_status
  before_action :set_access_control_headers
  after_action :set_csrf_header

  layout :choose_layout

  private

  def check_subscription_status
    return if current_company.blank?

    if current_company.subscription.canceled? && current_company.subscription.current_period_end < Time.current
      # TODO: make this link allow the user to update their subscription status too
      flash[:error] = 'Your subscription has expired. Please <a style="text-decoration-line: underline;" href="/settings/subscription/new">update your payment information</a> to continue using StaffPlan.'.html_safe
    end
  end

  def choose_layout
    current_user.blank? ? 'public' : 'application'
  end

  def current_company
    return @current_company if defined?(@current_company)
    return if current_user.blank?

    @current_company = current_user.current_company
  end

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = authenticate_by_session(User)
  end

  def my_staffplan_url
    if Prefab.enabled?('rails-views')
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
  helper_method :current_user

  def require_company_owner_or_admin!
    return if current_user.owner?(company: current_company) || current_user.admin?(company: current_company)

    redirect_to root_url, flash: { error: 'You are not authorized to access this page.' }
  end
  helper_method :current_company

  def require_user!
    return if current_company&.can_access?(user: current_user)

    # user may have their access revoked
    reset_session
    flash[:error] = 'Please sign in to continue using StaffPlan.' # rubocop:disable Rails/I18nLocaleTexts
    save_passwordless_redirect_location!(User) if request.get?
    redirect_to auth_sign_in_url
  end

  def set_access_control_headers
    response.set_header('Access-Control-Expose-Headers', 'x-csrf-token')
  end

  def set_csrf_header
    response.headers['X-CSRF-Token'] = form_authenticity_token
  end

  def set_paper_trail_whodunnit
    return unless current_user

    PaperTrail.request.whodunnit = current_user.id
  end
  helper_method :my_staffplan_url
end
