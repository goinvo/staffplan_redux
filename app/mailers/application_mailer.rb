# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  ActionMailer::MailDeliveryJob.queue_adapter = :solid_queue
  default from: 'noreply@staffplan.com'
  layout 'mailer'
end
