class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_filter :pick_layout
  before_filter :check_current_user, unless: :devise_controller?
  before_filter :check_current_company, unless: :devise_controller?
  before_filter :configure_permitted_parameters, if: :devise_controller?

  private
  
  def pick_layout
    if devise_controller?
      "devise"
    else
      "application"
    end
  end

  def check_current_user
    if current_user.blank?
      redirect_to new_user_session_url and return
    end
  end

  def check_current_company
    if current_company.blank?
      redirect_to companies_url and return
    end
  end

  def current_company
    current_user.try(:current_company)
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:first_name, :last_name]
    devise_parameter_sanitizer.for(:account_update) << [:first_name, :last_name]
  end
end
