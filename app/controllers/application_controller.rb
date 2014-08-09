class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_filter :check_current_user, unless: :devise_controller?
  
  def check_current_user
    if current_user.blank?
      redirect_to new_user_session_url and return
    end
  end
end