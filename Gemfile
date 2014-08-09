source 'https://rubygems.org'

ruby "2.1.2"

gem 'rails', '4.1.4'
gem 'pg'
gem 'sass-rails', '~> 4.0.3'
gem 'haml-rails'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails'
gem 'sdoc', '~> 0.4.0',        group: :doc
gem 'puma'
gem 'paper_trail'
gem 'bitmask_attributes'
gem 'active_model_serializers'
gem 'handlebars_assets'
gem 'draper'
gem 'compass-rails'
gem 'figaro'
gem 'devise'

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',      group: :development

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

gem 'bourbon'
gem 'neat'
gem 'bitters'
gem 'refills'
gem "bower-rails"


group :development, :test do
  gem 'rspec-rails'
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-remote',                               require: 'pry-remote'
  gem 'faker'
end

group :development do
  gem 'awesome_print',                            require: 'ap'
  gem 'quiet_assets'
  gem 'binding_of_caller'
  gem 'better_errors'
end

group :production do
  gem 'rails_12factor'
end

group :test do
  gem 'factory_girl_rails'
  gem 'timecop'
  gem 'capybara'
  gem 'capybara-email',             github: 'dockyard/capybara-email'
  gem 'capybara-screenshot'
  gem 'selenium-webdriver'
  gem 'email_spec'
  gem 'capybara-webkit'
  gem 'database_cleaner'
end
