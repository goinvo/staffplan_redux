class RegistrationsMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.registrations_mailer.create.subject
  #
  def create(registration)
    @greeting = "Hello from StaffPlan"

    @token = registration.token

    @magic_link = register_registration_url(
      registration,
      token: @token
    )

    mail to: registration.email, subject: "Welcome to StaffPlan"
  end
end
