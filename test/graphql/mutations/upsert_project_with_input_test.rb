# frozen_string_literal: true

require 'test_helper'

module Mutations
  class UpsertProjectWithInputTest < ActiveSupport::TestCase
    QUERY = <<~GRAPHQL
      mutation($input: ProjectAttributes!) {
        upsertProjectWithInput(input: $input) {
          id
          client {
            id
          }
          name
          cost
          paymentFrequency
          fte
          hours
          rateType
          hourlyRate
          status
          startsOn
          endsOn
          assignments {
            assignedUser {
              email
            }
            startsOn
          }
        }
      }
    GRAPHQL

    test 'creates a new project with assignments from valid params' do
      user = create(:user)
      assignee = create(:membership, company: user.current_company).user
      client = create(:client, company: user.current_company)
      name = Faker::Company.buzzword

      result = execute_graphql(
        QUERY,
        user:,
        variables: {
          input: {
            clientId: client.id,
            name:,
            status: Project::UNCONFIRMED,
            assignments: [{ userId: assignee.id, status: Assignment::PROPOSED }],
          },
        },
      )

      post_result = result['data']['upsertProjectWithInput']

      assert_nil result['errors']
      assert_equal client.id.to_s, post_result['client']['id']
      assert_equal name, post_result['name']
      assert_equal Project::UNCONFIRMED, post_result['status']
      assert_nil post_result['startsOn']
      assert_nil post_result['endsOn']
      assert_equal 1, post_result['assignments'].length
      assert_equal assignee.email, post_result['assignments'].first['assignedUser']['email']
    end

    test 'creates a new project with unassigned assignments from valid params' do
      user = create(:user)
      starts_on = Date.tomorrow.iso8601
      client = create(:client, company: user.current_company)
      name = Faker::Company.buzzword

      result = execute_graphql(
        QUERY,
        user:,
        variables: {
          input: {
            clientId: client.id,
            name:,
            status: Project::UNCONFIRMED,
            assignments: [{ startsOn: starts_on, status: Assignment::PROPOSED }],
          },
        },
      )

      post_result = result['data']['upsertProjectWithInput']

      assert_nil result['errors']
      assert_equal client.id.to_s, post_result['client']['id']
      assert_equal name, post_result['name']
      assert_equal Project::UNCONFIRMED, post_result['status']
      assert_nil post_result['startsOn']
      assert_nil post_result['endsOn']
      assert_equal 1, post_result['assignments'].length
      assert_nil post_result['assignments'].first['assignedUser']
      assert_equal starts_on, post_result['assignments'].first['startsOn']
    end

    test 'does not allow a client_id from another company' do
      user = create(:user)
      client = create(:client, company: user.current_company)
      other_client = create(:client)

      assert_not_equal client.company, other_client.company
      assert_not_includes other_client.company.users, user

      result = nil
      assert_no_difference -> { Project.count } do
        result = execute_graphql(
          QUERY,
          user:,
          variables: { input: { clientId: other_client.id, name: Faker::Company.buzzword } },
        )
      end

      assert_equal 'Client not found', result['errors'].first['message']
    end

    test 'allows optional project fields to be set to null' do
      starts_on = 2.weeks.from_now
      ends_on = 10.weeks.from_now
      project = create(:project, starts_on:, ends_on:)
      user = User.find_by(current_company_id: project.company.id)

      assert_equal starts_on.to_date, project.starts_on
      assert_equal ends_on.to_date, project.ends_on

      result = execute_graphql(QUERY, user:, variables: { input: { id: project.id, startsOn: nil, endsOn: nil } })

      assert_nil result['errors']

      post_result = result['data']['upsertProjectWithInput']

      assert_nil post_result['startsOn']
      assert_nil post_result['endsOn']
    end

    test 'updates a project with valid params' do
      project = create(:project)
      user = User.find_by(current_company_id: project.company.id)
      starts_on = 2.weeks.from_now.to_date.iso8601
      ends_on = 10.weeks.from_now.to_date.iso8601

      result = execute_graphql(
        QUERY,
        user:,
        variables: {
          input: {
            id: project.id,
            clientId: project.client.id,
            name: "#{project.name} updated",
            status: Project::COMPLETED,
            cost: 1000.00,
            paymentFrequency: Project::ANNUALLY,
            fte: 1.25,
            hours: 1_000,
            rateType: 'hourly',
            hourlyRate: 1_000,
            startsOn: starts_on,
            endsOn: ends_on,
          },
        },
      )

      assert_nil result['errors']

      post_result = result['data']['upsertProjectWithInput']

      assert_equal project.client.id.to_s, post_result['client']['id']
      assert_equal "#{project.name} updated", post_result['name']
      assert_equal Project::COMPLETED, post_result['status']
      assert_in_delta(1000.00, post_result['cost'])
      assert_equal Project::ANNUALLY, post_result['paymentFrequency']
      assert_in_delta(1.25, post_result['fte'])
      assert_equal 1_000, post_result['hours']
      assert_equal 'hourly', post_result['rateType']
      assert_equal 1_000, post_result['hourlyRate']
      assert_equal starts_on, post_result['startsOn']
      assert_equal ends_on, post_result['endsOn']
    end

    test 'does not allow client_id to be overridden' do
      project = create(:project)
      user = project.company.users.first
      other_client = create(:client)

      assert_not_equal project.client.company, other_client.company

      result = execute_graphql(QUERY, user:, variables: { input: { id: project.id, clientId: other_client.id } })

      assert_equal project.client.id.to_s, result['data']['upsertProjectWithInput']['client']['id']
    end

    test "returns not found for a project id that doesn't belong to the company" do
      project = create(:project)
      user = project.company.users.first
      second_project = create(:project)

      assert_not_equal project.company, second_project.company

      result = execute_graphql(QUERY, user:, variables: { input: { id: second_project.id, name: 'new name' } })

      assert_equal 'Project not found', result['errors'].first['message']
    end
  end
end
