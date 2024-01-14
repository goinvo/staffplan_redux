class RegistrationsController < ApplicationController
  include Passwordless::ControllerHelpers
  def new
    @registration = Registration.new
  end

  def create
    create_params = registration_params.merge(
      ip_address: request.remote_ip,
    )

    @registration = Registration.new(create_params)

    if @registration.save
      RegistrationsMailer.create(@registration).deliver_now
      redirect_to auth_sign_in_url, notice: "Thanks for your interest in StaffPlan! Check your e-mail for next steps on how to confirm your account."
    else
      render :new
    end
  end

  def register
    registration = Registration.find_by!(identifier: params[:id])

    if registration.valid_token_digest?(params[:token])
      registration.register!
      sign_in(create_passwordless_session(registration.user))
      redirect_to root_url, notice: "Thanks for registering! You're now signed in."
    else
      redirect_to auth_sign_in_url, notice: "Sorry, that link is invalid."
    end
  rescue Registration::RegistrationNotAvailableError
    redirect_to auth_sign_in_url, notice: "Sorry, that link is invalid."
  end

  private

  def registration_params
    params.require(:registration).permit(:name, :email)
  end
end
