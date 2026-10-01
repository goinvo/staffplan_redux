# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@staffplan.com'
  layout 'mailer'
end
