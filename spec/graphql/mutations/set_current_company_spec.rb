# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mutations::SetCurrentCompany do

  def query_string
    <<-GRAPHQL
      mutation($companyId: ID!) {
        setCurrentCompany(companyId: $companyId) {
          id
          name
        }
      }
    GRAPHQL
  end

  context "when a user is signed in" do
    it "succeeds if the user is an active member of the company" do
      membership = create(:membership)
      user = membership.user
      other_company = create(
        :membership,
        user: user
      ).company

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: membership.company
        },
        variables: {
          companyId: other_company.id
        }
      )

      post_result = result["data"]["setCurrentCompany"]
      expect(post_result["id"]).to eq(other_company.id.to_s)
      expect(post_result["name"]).to eq(other_company.name)
    end

    it "fails if the user is not an active member of the company" do
      membership = create(:membership)
      user = membership.user
      other_company = create(
        :membership,
        status: "inactive",
        user: user
      ).company

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: membership.company
        },
        variables: {
          companyId: other_company.id
        }
      )

      expect(result["errors"].length).to eq(1)
      expect(result["errors"].first["message"]).to eq("Company not found.")
    end

    it "fails if the user has no membership with the company" do
      membership = create(:membership)
      user = membership.user
      other_company = create(:membership).company

      expect(other_company.users).to_not include(user)

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: membership.company
        },
        variables: {
          companyId: other_company.id
        }
      )

      expect(result["errors"].length).to eq(1)
      expect(result["errors"].first["message"]).to eq("Company not found.")
    end
  end
end