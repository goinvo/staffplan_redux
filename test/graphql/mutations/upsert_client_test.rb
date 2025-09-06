# frozen_string_literal: true

require 'test_helper'

module Mutations
  class UpsertClientTest < ActiveSupport::TestCase
    describe 'resolve' do
      it 'creates a new client with valid params' do
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
            current_company: user.current_company,
          },
          variables: {
            name: project_name = Faker::Company.buzzword,
            status: Enums::ClientStatus.values['active'].value,
            description: project_description = Faker::Company.bs,
          },
        )

        post_result = result['data']['upsertClient']

        assert_nil result['errors']
        assert_equal project_name, post_result['name']
        assert_equal Client::ACTIVE, post_result['status']
        assert_equal project_description, post_result['description']
      end

      it 'updates a client with valid params' do
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
            current_company: user.current_company,
          },
          variables: {
            id: client.id,
            name: client_name = "#{client.name} updated",
            description: client_description = "#{client.description} updated",
            status: Client::ARCHIVED,
          },
        )

        post_result = result['data']['upsertClient']

        assert_nil result['errors']
        assert_equal client_name, post_result['name']
        assert_equal client_description, post_result['description']
        assert_equal Client::ARCHIVED, post_result['status']
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

        assert_not_includes user.companies, client.company

        result = StaffplanReduxSchema.execute(
          query_string,
          context: {
            current_user: user,
            current_company: user.current_company,
          },
          variables: {
            id: client.id,
            name: 'a new name',
          },
        )

        post_result = result['errors']

        assert_equal 'Client not found', post_result.first['message']
      end
    end
  end
end
