# frozen_string_literal: true

require "test_helper"

class StaffPlanGraphQLSchemaTest < ActiveSupport::TestCase
  describe "StaffPlan GraphQL Schema dump" do
    it "matches the printed schema" do
      current_definition = StaffplanReduxSchema.to_definition
      printout_definition = File.read(Rails.root.join("app/graphql/schema.graphql"))
      # If this fails, update the printed schema with `bundle exec rake dump_schema`
      assert_equal printout_definition, current_definition
    end
  end
end