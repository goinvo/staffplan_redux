# Helper methods for all tests
module TestHelperMethods
  # Add any shared helper methods here
end

# Include in all test classes
ActiveSupport::TestCase.include TestHelperMethods
ActionDispatch::IntegrationTest.include TestHelperMethods