# frozen_string_literal: true

class CompanyMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.billing_mailer.subscription_updated.subject
  #
  def welcome(company, user)
    @greeting = "Someone from #{company.name} has invited you to StaffPlan!"
    @company = company
    @user = user

    mail to: user.email, subject: 'You have been invited to StaffPlan!'
  end
end
