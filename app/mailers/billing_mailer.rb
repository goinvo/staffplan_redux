# frozen_string_literal: true

class BillingMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.billing_mailer.subscription_updated.subject
  #
  def subscription_updated(company, new_subscription_count)
    @greeting = "We've updated your StaffPlan subscription count!"
    @company = company
    @new_subscription_count = new_subscription_count

    mail to: @company.owners.map(&:email), subject: 'StaffPlan Subscription Updated'
  end
end
