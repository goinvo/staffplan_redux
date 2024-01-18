class ApplicationController < ActionController::Base
  include Passwordless::ControllerHelpers

  helper_method :current_user

  layout :choose_layout

  private

  def choose_layout
    current_user.blank? ? 'public' : 'application'
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = authenticate_by_session(User)
  end
  helper_method :current_user

  def current_company
    return @current_company if defined?(@current_company)
    @current_company = current_user.current_company
  end
  helper_method :current_company

  def require_user!
    return if current_user
    save_passwordless_redirect_location!(User)
    redirect_to auth_sign_in_url, flash: { notice: 'Please sign in.' }
  end

  def require_company_owner_or_admin!
    return if current_user.owner? || current_user.admin?
    redirect_to root_url, flash: { error: 'You are not authorized to access this page.' }
  end
end
