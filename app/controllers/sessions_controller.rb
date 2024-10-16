class SessionsController < Passwordless::SessionsController

  before_action :require_params, only: :create

  private

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
