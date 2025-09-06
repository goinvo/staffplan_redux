# frozen_string_literal: true

# Helper methods for all tests
module TestHelperMethods
  # Add any shared helper methods here
end

# Include in all test classes
ActiveSupport.on_load(:active_support_test_case) { include TestHelperMethods }
ActiveSupport.on_load(:action_dispatch_integration_test) { include TestHelperMethods }
