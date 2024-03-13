# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mutations::UpsertClient do

  context "resolve" do
    it "creates a new client with valid params" do
      query_string = <<-GRAPHQL
        mutation($name: String, $status: String, $description: String) {
          upsertClient(name: $name, status: $status, description: $description) {
            id
            name
            status
            description
          }
        }
      GRAPHQL

      user = create(:user)

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: user.current_company
        },
        variables: {
          name: project_name = Faker::Company.buzzword,
          status: Enums::ClientStatus.values["active"].value,
          description: project_description = Faker::Company.bs
        }
      )

      post_result = result["data"]["upsertClient"]
      expect(result["errors"]).to be_nil
      expect(post_result["name"]).to eq(project_name)
      expect(post_result["status"]).to eq(Client::ACTIVE)
      expect(post_result["description"]).to eq(project_description)
    end

    it "updates a client with valid params" do
      query_string = <<-GRAPHQL
        mutation($id: ID, $name: String, $description: String, $status: String) {
          upsertClient(id: $id, name: $name, description: $description, status: $status) {
            id
            name
            description
            status
          }
        }
      GRAPHQL

      client = create(:client)
      user = client.company.users.first

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: user.current_company
        },
        variables: {
          id: client.id,
          name: client_name = client.name.to_s + " updated",
          description: client_description = client.description.to_s + " updated",
          status: Client::ARCHIVED
        }
      )

      post_result = result["data"]["upsertClient"]
      expect(result["errors"]).to be_nil
      expect(post_result["name"]).to eq(client_name)
      expect(post_result["description"]).to eq(client_description)
      expect(post_result["status"]).to eq(Client::ARCHIVED)
    end

    it "raises a 404 if given an project id that doesn't exist on the company" do
      query_string = <<-GRAPHQL
        mutation($id: ID, $name: String) {
          upsertClient(id: $id, name: $name) {
            id
            name
          }
        }
      GRAPHQL

      client = create(:client)
      user = create(:membership).user

      expect(user.companies).to_not include(client.company)

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: user.current_company
        },
        variables: {
          id: client.id,
          name: "a new name"
        }
      )

      post_result = result["errors"]
      expect(post_result.first["message"]).to eq("Client not found")
    end
  end
end