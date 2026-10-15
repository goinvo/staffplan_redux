# frozen_string_literal: true

# Signs out every user except the ones named, so their next request sends them through sign in.
#
#   bin/rails runner script/sign_out_users.rb keep@example.com also@example.com            # preview
#   bin/rails runner script/sign_out_users.rb keep@example.com also@example.com --confirm  # sign out

require_relative '../config/environment'

confirm = ARGV.delete('--confirm')
emails = ARGV.map { it.strip.downcase }.uniq
abort 'Usage: bin/rails runner script/sign_out_users.rb EMAIL... [--confirm]' if emails.empty?

kept = User.where(User.arel_table[:email].lower.in(emails)).to_a
missing = emails - kept.map { it.email.downcase }
abort "No user has the email #{missing.join(', ')}; nobody was signed out." if missing.any?

sessions = Passwordless::Session
  .where(authenticatable_type: User.name, expires_at: Time.current..)
  .where.not(authenticatable_id: kept.map(&:id))
summary = "#{sessions.distinct.count(:authenticatable_id)} users (#{sessions.count} sessions), " \
          "keeping #{kept.map(&:email).join(', ')}"

if confirm
  sessions.update_all(expires_at: Time.current, updated_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
  puts "Signed out #{summary}."
else
  puts "Would sign out #{summary}. Rerun with --confirm to sign them out."
end
