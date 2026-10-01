# frozen_string_literal: true

require 'test_helper'

module Mutations
  class UpsertClientWithInputTest < ActiveSupport::TestCase
    QUERY = <<~GRAPHQL
      mutation($input: ClientAttributes!) {
        upsertClientWithInput(input: $input) {
          id
          name
          description
          status
        }
      }
    GRAPHQL

    test 'creates a new client with valid params' do
      user = create(:user)
      name = Faker::Company.buzzword
      description = Faker::Company.bs

      result = execute_graphql(
        QUERY,
        user:,
        variables: { input: { name:, status: Enums::ClientStatus.values['active'].value, description: } },
      )

      post_result = result['data']['upsertClientWithInput']

      assert_nil result['errors']
      assert_equal name, post_result['name']
      assert_equal Client::ACTIVE, post_result['status']
      assert_equal description, post_result['description']
    end

    test 'allows optional fields to be nulled out' do
      description = Faker::Lorem.sentence
      client = create(:client, description:)
      user = client.company.users.first

      assert_equal description, client.description

      result = execute_graphql(QUERY, user:, variables: { input: { id: client.id, description: nil } })

      assert_nil result['errors']
      assert_nil result['data']['upsertClientWithInput']['description']
    end

    test 'updates a client with valid params' do
      client = create(:client)
      user = client.company.users.first
      name = "#{client.name} updated"
      description = "#{client.description} updated"

      result = execute_graphql(
        QUERY,
        user:,
        variables: { input: { id: client.id, name:, description:, status: Client::ARCHIVED } },
      )

      post_result = result['data']['upsertClientWithInput']

      assert_nil result['errors']
      assert_equal name, post_result['name']
      assert_equal description, post_result['description']
      assert_equal Client::ARCHIVED, post_result['status']
    end

    test "returns not found for a client id that doesn't belong to the company" do
      client = create(:client)
      user = create(:membership).user

      assert_not_includes user.companies, client.company

      result = execute_graphql(QUERY, user:, variables: { input: { id: client.id, name: 'a new name' } })

      assert_equal 'Client not found', result['errors'].first['message']
    end
  end
end
