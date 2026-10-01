# frozen_string_literal: true

require 'test_helper'

module Mutations
  class UpsertAssignmentWithInputTest < ActiveSupport::TestCase
    QUERY = <<~GRAPHQL
      mutation($input: AssignmentAttributes!) {
        upsertAssignmentWithInput(input: $input) {
          id
          project {
            id
          }
          assignedUser {
            id
          }
          status
          estimatedWeeklyHours
          startsOn
          endsOn
        }
      }
    GRAPHQL

    test 'creates a new proposed, unassigned assignment' do
      user = create(:user)
      project = project_for_company(user.current_company)

      result = execute_graphql(QUERY, user:, variables: { input: { projectId: project.id, status: Assignment::PROPOSED } })

      post_result = result['data']['upsertAssignmentWithInput']

      assert_nil result['errors']
      assert_equal project.id.to_s, post_result['project']['id']
      assert_nil post_result['assignedUser']
      assert_equal Assignment::PROPOSED, post_result['status']
      assert_nil post_result['startsOn']
      assert_nil post_result['endsOn']
    end

    test 'creates a new assignment with valid params' do
      user = create(:user)
      project = project_for_company(user.current_company)

      result = execute_graphql(
        QUERY,
        user:,
        variables: { input: { projectId: project.id, userId: user.id, status: Assignment::PROPOSED } },
      )

      post_result = result['data']['upsertAssignmentWithInput']

      assert_nil result['errors']
      assert_equal project.id.to_s, post_result['project']['id']
      assert_equal user.id.to_s, post_result['assignedUser']['id']
      assert_equal Assignment::PROPOSED, post_result['status']
      assert_nil post_result['startsOn']
      assert_nil post_result['endsOn']
    end

    test 'updates the assignment with valid params' do
      user = create(:user)
      assignment = assignment_for_user(user:, status: Assignment::PROPOSED)
      starts_on = 2.weeks.from_now.to_date.iso8601
      ends_on = 10.weeks.from_now.to_date.iso8601

      result = execute_graphql(
        QUERY,
        user:,
        variables: {
          input: {
            id: assignment.id,
            projectId: assignment.project_id,
            userId: assignment.user_id,
            status: Assignment::ACTIVE,
            estimatedWeeklyHours: 40,
            startsOn: starts_on,
            endsOn: ends_on,
          },
        },
      )

      post_result = result['data']['upsertAssignmentWithInput']

      assert_nil result['errors']
      assert_equal Assignment::ACTIVE, post_result['status']
      assert_equal 40, post_result['estimatedWeeklyHours']
      assert_equal starts_on, post_result['startsOn']
      assert_equal ends_on, post_result['endsOn']
    end

    test 'renders validation errors' do
      user = create(:user)
      assignment = assignment_for_user(user:)

      result = execute_graphql(
        QUERY,
        user:,
        variables: {
          input: {
            id: assignment.id,
            projectId: create(:project).id,
            userId: assignment.user_id,
            status: Assignment::ACTIVE,
          },
        },
      )

      assert_equal 1, result['errors'].length
      assert_equal 'Project and user must belong to the same company', result['errors'].first['message']
    end

    test "returns not found for an assignment id that doesn't belong to the company" do
      user = create(:user)
      assignment = assignment_for_user(user:)

      result = execute_graphql(
        QUERY,
        user:,
        variables: {
          input: {
            id: assignment_for_user(user: create(:user)).id,
            projectId: assignment.project_id,
            userId: assignment.user_id,
            status: Assignment::ACTIVE,
          },
        },
      )

      assert_equal 'Assignment not found', result['errors'].first['message']
    end
  end
end
