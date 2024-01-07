require "rails_helper"

RSpec.describe GraphqlController, type: :request do
  context "when the user is not signed in" do
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

      expect(response.status).to eq(404)
    end
  end
end