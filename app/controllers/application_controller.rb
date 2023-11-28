class ApplicationController < ActionController::Base
  include Passwordless::ControllerHelpers

  helper_method :current_user

  layout :choose_layout

  private

  def choose_layout
    current_user.blank? ? 'public' : 'application'
  end

  def current_user
    @current_user ||= authenticate_by_session(User)
  end
  helper_method :current_user

  def current_company
    @current_company ||= current_user.current_company
  end
  helper_method :current_company

  def require_user!
    return if current_user
    save_passwordless_redirect_location!(User)
    redirect_to auth_sign_in_url, flash: { notice: 'Please sign in.' }
  end
end
