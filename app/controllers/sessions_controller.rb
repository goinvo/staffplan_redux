class SessionsController < Passwordless::SessionsController

  before_action :redirect_to_dashboard_if_authenticated, only: %i(new)
  before_action :require_params, only: :create

  def confirm
    Rails.logger.debug "request.session_options[:id]: #{request.session_options[:id]}"
    Rails.logger.debug "request.env\n#{request.env.inspect}"
    Rails.logger.debug "session.keys before super: #{session.keys}"
    super
    Rails.logger.debug "session.keys after super: #{session.keys}"
  end

  def new
    Rails.logger.debug "request.session_options[:id]: #{request.session_options[:id]}"
    Rails.logger.debug "request.env\n#{request.env.inspect}"
    Rails.logger.debug "session.keys before super: #{session.keys}"
    super
    Rails.logger.debug "session.keys after super: #{session.keys}"
  end


  private

  def redirect_to_dashboard_if_authenticated
    if current_user.present?
      redirect_to my_staffplan_url(current_user), allow_other_host: true
    end
  end

  def require_params
    if params[:passwordless].blank?
      redirect_to auth_sign_in_url, alert: "Sorry, please try that again."
    end
  end

  def my_staffplan_url(current_user)
    case Rails.env
    when "production"
      "https://ui.staffplan.com/people/#{current_user.id}"
    else
      "http://localhost:8080/people/#{current_user.id}"
    end
  end
  helper_method :my_staffplan_url
end
