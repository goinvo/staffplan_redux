# frozen_string_literal: true

# Runs a GraphQL query against the schema as the given user
module GraphqlHelpers
  def execute_graphql(query, user:, company: user.current_company, variables: {})
    StaffplanReduxSchema.execute(
      query,
      context: { current_user: user, current_company: company },
      variables: variables,
    )
  end
end

ActiveSupport.on_load(:active_support_test_case) { include GraphqlHelpers }
