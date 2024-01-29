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
    return if current_user.blank?
    @current_company = current_user.current_company
  end
  helper_method :current_company

  def require_user!
    return if current_company && current_company.can_access?(user: current_user)

    # user may have their access revoked
    reset_session
    flash[:error] = 'Please sign in to continue using StaffPlan.'
    save_passwordless_redirect_location!(User) if request.get?
    redirect_to auth_sign_in_url
  end

  def require_company_owner_or_admin!
    return if current_user.owner?(company: current_company) || current_user.admin?(company: current_company)
    redirect_to root_url, flash: { error: 'You are not authorized to access this page.' }
  end

  def set_paper_trail_whodunnit
    return unless current_user
    PaperTrail.request.whodunnit = current_user.id
  end
end
