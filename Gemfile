# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.4.4'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '8.0.2'

gem 'sprockets-rails'

gem 'pg', '~> 1.6'

gem 'importmap-rails'
gem 'mission_control-jobs'
gem 'money'
gem 'prefab-cloud-ruby'
gem 'puma', '>= 5.0'
gem 'rack-cors'
gem 'recaptcha'
gem 'solid_queue'
gem 'stimulus-rails'
gem 'stripe'
gem 'tailwindcss-rails'
gem 'turbo-rails'

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'graphiql-rails'
gem 'graphql', '~> 2.5'
gem 'paper_trail'
gem 'passwordless', '~> 1.8'
gem 'tzinfo-data', platforms: %i[windows jruby]
gem 'view_component'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false
gem 'faker'

gem 'rollbar'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem 'aws-sdk-s3', require: false
gem 'image_processing', '~> 1.14'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'bullet'
  gem 'debug', platforms: %i[mri windows]
  gem 'dotenv-rails'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  gem 'foreman'
  gem 'letter_opener'
  gem 'letter_opener_web'
  gem 'pry'
  gem 'rbs'

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem 'rubocop-capybara'
  gem 'rubocop-factory_bot'
  gem 'rubocop-graphql'
  gem 'rubocop-minitest'
  gem 'rubocop-ordered_methods'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rails-omakase', require: false
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'

  gem 'factory_bot_rails'
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'minitest-spec-rails'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers', '~> 6.5'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end
