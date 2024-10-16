Passwordless.configure do |config|
  config.default_from_address = "noreply@staffplan.com"
  config.parent_mailer = "ActionMailer::Base"
  config.restrict_token_reuse = true # A token/link can only be used once
  config.token_generator = Passwordless::ShortTokenGenerator.new # Used to generate magic link tokens.

  config.expires_at = lambda { 1.year.from_now } # How long until a signed in session expires.
  config.timeout_at = lambda { 10.minutes.from_now } # How long until a token/magic link times out.

  config.redirect_back_after_sign_in = true # When enabled the user will be redirected to their previous page, or a page specified by the `destination_path` query parameter, if available.
  config.redirect_to_response_options = {} # Additional options for redirects.
  config.success_redirect_path = -> (current_user) {
    case Rails.env
    when 'production'
      "https://ui.staffplan.com/people/#{current_user.id}"
    else
      "http://localhost:8080/people/#{current_user.id}"
    end
  }
  config.failure_redirect_path = '/' # After a sign in fails
  config.sign_out_redirect_path = '/' # After a user signs out
  config.paranoid = true
end
