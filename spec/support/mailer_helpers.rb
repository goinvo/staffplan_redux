module Helpers
  module Mailers
    def clear_emails
      ActionMailer::Base.deliveries = []
    end

    def last_email
      ActionMailer::Base.deliveries.last
    end

    def email_count
      ActionMailer::Base.deliveries.count
    end
  end
end
