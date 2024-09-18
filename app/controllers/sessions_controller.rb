class SessionsController < Passwordless::SessionsController

  before_action :require_params, only: :create

  private

  def require_params
    if params[:passwordless].blank?
      redirect_to auth_sign_in_url, alert: "Sorry, please try that again."
    end
  end
end
