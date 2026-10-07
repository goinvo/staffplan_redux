# frozen_string_literal: true

module RailsUi
  module_function

  def allowlisted_emails
    Rails.configuration.x.rails_ui_emails.split(',').map { it.strip.downcase }.compact_blank
  end

  def enabled_for?(user)
    return false if user.blank?
    return true if Rails.configuration.x.rails_ui_enabled == 'true'

    allowlisted_emails.include?(user.email.strip.downcase)
  end

  def react_url(path)
    "#{Rails.configuration.x.react_ui_url}#{path}"
  end

  def url(user, path)
    enabled_for?(user) ? path : react_url(path)
  end
end
