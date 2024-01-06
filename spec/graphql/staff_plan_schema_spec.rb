# frozen_string_literal: true

require "rails_helper"

RSpec.describe "StaffPlan GraphQL Schema dump" do
  it "matches the printed schema" do
    current_definition = StaffplanReduxSchema.to_definition
    printout_definition = File.read(Rails.root.join("app/graphql/schema.graphql"))
    # If this fails, update the printed schema with `bundle exec rake dump_schema`
    expect(current_definition).to eq(printout_definition)
  end
end