ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require "minitest/spec"
require "minitest/autorun"
require "minitest/reporters"
require "passwordless/test_helpers"
require "view_component/test_helpers"
require "view_component/system_test_helpers"
require "capybara/rails"
require 'vcr'
require 'pry'

# Configure Minitest reporters
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

Dir[Rails.root.join('test', 'support', '**', '*.rb')].sort.each { |f| require f }

# Check for pending migrations and apply them before tests are run
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

# VCR configuration
VCR.configure do |config|
  config.cassette_library_dir = "#{::Rails.root}/test/cassettes"
  config.ignore_localhost = true
  config.hook_into :webmock
  config.filter_sensitive_data('<BEARER_TOKEN>') { |interaction|
    auths = interaction.request.headers['Authorization'].first
    if (match = auths.match /^Bearer\s+([^,\s]+)/ )
      match.captures.first
    end
  }
end

# Module to add VCR support to Minitest
module VCRSupport
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def use_vcr_cassette(cassette_name = nil)
      @vcr_cassette_name = cassette_name
    end

    def vcr_cassette_name
      @vcr_cassette_name
    end
  end

  def setup
    super
    if self.class.vcr_cassette_name || respond_to?(:vcr_cassette_name)
      cassette_name = self.class.vcr_cassette_name || default_vcr_cassette_name
      VCR.insert_cassette(cassette_name)
    end
  end

  def teardown
    VCR.eject_cassette if VCR.current_cassette
    super
  end

  private

  def default_vcr_cassette_name
    class_name = self.class.name.underscore.gsub(/_test$/, "")
    method_name = @NAME || self.name.tr(" ", "_")
    "#{class_name}/#{method_name}"
  end
end

# Shoulda Matchers configuration
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Use fixtures for all tests
  fixtures :all

  # Setup all ActiveSupport::TestCase subclasses to include FactoryBot methods
  include FactoryBot::Syntax::Methods
  include VCRSupport

  # Include shoulda matchers
  extend Shoulda::Matchers::ActiveModel
  extend Shoulda::Matchers::ActiveRecord

  # Add more helper methods to be used by all tests here...
end

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  # Reset sessions and driver between tests
  teardown do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers if defined?(Devise)
end

class ActionView::TestCase
  include ViewComponent::TestHelpers
  include Capybara::Minitest::Assertions
end

# Setup for system tests
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include ViewComponent::SystemTestHelpers
  
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]

  setup do
    Rails.application.default_url_options[:host] = Capybara.server_host
  end

  teardown do
    Rails.application.default_url_options[:host] = nil
  end
end