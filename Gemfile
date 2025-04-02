source "https://rubygems.org"

ruby "3.4.1"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "8.0.2"

gem "sprockets-rails"

gem "pg", "~> 1.5"

gem "puma", ">= 5.0"
gem 'rack-cors'
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "stripe"
gem "money"
gem "tailwindcss-rails"
gem "recaptcha"
gem "kamal", "2.5.3"
gem "prefab-cloud-ruby"
gem "solid_queue"
gem "mission_control-jobs"

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem 'paper_trail'
gem "passwordless", "~> 1.8"
gem "graphql", "~> 2.5"
gem "graphiql-rails"
gem "view_component"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false
gem "faker"

gem 'rollbar'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.14"
gem "aws-sdk-s3", require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]
  gem "bullet"
  gem 'dotenv-rails'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  gem "letter_opener"
  gem "letter_opener_web"
  gem "foreman"
  gem 'pry'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"

  gem "rspec-rails"
  gem "factory_bot_rails"
  gem 'shoulda-matchers', '~> 6.4'
  gem "timecop"
  gem "webmock"
  gem "vcr"
  gem 'rails-controller-testing'
end
