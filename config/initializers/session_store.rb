Rails.application.config.session_store(
  :cookie_store,
  key: '_staffplan_redux_session',
  domain: :all,
  tld_length: 2,
  secure: Rails.env.production?,
  same_site: :lax
)
