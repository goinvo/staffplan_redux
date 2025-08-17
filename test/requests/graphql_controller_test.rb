require "test_helper"

class GraphqlControllerTest < ActionDispatch::IntegrationTest
  describe "when the user is not signed in" do
    it "returns a 404" do
      query = <<~GQL
        mutation {
          setCurrentCompany(companyId: #{create(:company).id}) {
            id
            name
          }
        }
      GQL

      post '/graphql', params: { query: query }

      assert_equal 403, response.status
    end
  end
end