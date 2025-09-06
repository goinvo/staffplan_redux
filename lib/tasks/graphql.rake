# frozen_string_literal: true

# lib/tasks/graphql.rake

namespace :graphql do
  desc 'dumps the GraphQL schema to a file for consistency validations in tests'
  task dump_schema: :environment do
    # Get a string containing the definition in GraphQL IDL:
    schema_defn = StaffplanReduxSchema.to_definition
    # Choose a place to write the schema dump:
    schema_path = 'app/graphql/schema.graphql'
    # Write the schema dump to that file:
    Rails.root.join(schema_path).write(schema_defn)
    puts "Updated #{schema_path}"
  end
end
