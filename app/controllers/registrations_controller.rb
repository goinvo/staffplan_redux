# frozen_string_literal: true

class RegistrationsController < ApplicationController
  include Passwordless::ControllerHelpers

  def create
    create_params = registration_params.merge(
      ip_address: request.remote_ip,
    )

    @registration = Registration.new(create_params)

    if captcha_enabled? && !verify_recaptcha
      flash.now[:alert] = 'Sorry, please try that again.'
      render :new and return
    end

    if @registration.save
      RegistrationsMailer.create(@registration).deliver_now
      redirect_to auth_sign_in_url, notice: 'Thanks for your interest in StaffPlan! Check your e-mail for next steps on how to confirm your account.'
    else
      flash.now[:alert] = 'Sorry, please try that again.'
      render :new
    end
  end

  def new
    @registration = Registration.new
  end

  def register
    registration = Registration.find_by!(identifier: params[:id])

    if registration.valid_token_digest?(params[:token])
      registration.register!
      sign_in(create_passwordless_session(registration.user))
      redirect_to root_url, notice: "Thanks for registering! You're now signed in." # rubocop:disable Rails/I18nLocaleTexts
    else
      redirect_to auth_sign_in_url, notice: 'Sorry, that link is invalid.' # rubocop:disable Rails/I18nLocaleTexts
    end
  rescue Registration::RegistrationNotAvailableError
    redirect_to auth_sign_in_url, notice: 'Sorry, that link is invalid.' # rubocop:disable Rails/I18nLocaleTexts
  end

  private

  def captcha_enabled?
    true if Rails.env.production?

    Rails.application.credentials.recaptcha_site_key.present? &&
      Rails.application.credentials.recaptcha_secret_key.present?
  end
  helper_method :captcha_enabled?

  def registration_params
    params.expect(registration: %i[company_name name email])
  rescue ActionController::ParameterMissing
    {}
  end
end
