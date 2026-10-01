# frozen_string_literal: true

require 'test_helper'

module Mutations
  class DeleteAssignmentTest < ActiveSupport::TestCase
    QUERY = <<~GRAPHQL
      mutation($assignmentId: ID!) {
        deleteAssignment(assignmentId: $assignmentId) {
          id
          status
        }
      }
    GRAPHQL

    test 'destroys an unassigned (TBD) assignment' do
      project = create(:project)
      assignment = create(:assignment, :unassigned, project:)
      company = project.company

      result = execute_graphql(QUERY, user: company.users.first, company:, variables: { assignmentId: assignment.id })

      post_result = result['data']['deleteAssignment']

      assert_nil result['errors']
      assert_equal assignment.id.to_s, post_result['id']
      assert_equal Assignment::PROPOSED, post_result['status']
      assert_raises(ActiveRecord::RecordNotFound) { assignment.reload }
    end

    test 'allows deletion of an assigned assignment with no hours recorded' do
      assignment = create(:assignment)
      create(:work_week, assignment:, actual_hours: 0)
      company = assignment.project.company

      result = execute_graphql(QUERY, user: company.users.first, company:, variables: { assignmentId: assignment.id })

      post_result = result['data']['deleteAssignment']

      assert_nil result['errors']
      assert_raises(ActiveRecord::RecordNotFound) { assignment.reload }
      assert_equal assignment.id.to_s, post_result['id']
      assert_equal Assignment::ACTIVE, post_result['status']
    end

    test 'blocks deletion of an assigned assignment with hours recorded' do
      assignment = create(:assignment)
      create(:work_week, assignment:, actual_hours: 15)

      assert_equal 1, assignment.reload.work_weeks.count

      company = assignment.project.company

      result = execute_graphql(QUERY, user: company.users.first, company:, variables: { assignmentId: assignment.id })

      post_result = result['data']['deleteAssignment']

      assert_equal "Cannot delete an assignment that's assigned with hours recorded. Try archiving the assignment instead.",
                   result['errors'].first['message']
      assert_predicate assignment.reload, :persisted?
      assert_equal assignment.id.to_s, post_result['id']
      assert_equal Assignment::ACTIVE, post_result['status']
    end
  end
end
