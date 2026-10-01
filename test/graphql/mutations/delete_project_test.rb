# frozen_string_literal: true

require 'test_helper'

module Mutations
  class DeleteProjectTest < ActiveSupport::TestCase
    test 'returns an error when the project cannot be destroyed' do
      query = <<~GRAPHQL
        mutation($projectId: ID!) {
          deleteProject(projectId: $projectId) {
            id
            status
          }
        }
      GRAPHQL

      project = create(:project)
      company = project.client.company
      user = create(:membership, company:).user
      assignment = create(:assignment, project:, user:)
      create(:work_week, assignment:, actual_hours: 5)

      result = execute_graphql(query, user:, company:, variables: { projectId: project.id })

      post_result = result['data']['deleteProject']

      assert_equal 'Cannot delete a project that has assignments with hours recorded. Try archiving the project instead.',
                   result['errors'].first['message']
      assert_predicate project.reload, :persisted?
      assert_equal project.id.to_s, post_result['id']
      assert_equal Project::CONFIRMED, post_result['status']
    end

    test 'destroys a project that can be destroyed' do
      query = <<~GRAPHQL
        mutation($projectId: ID!) {
          deleteProject(projectId: $projectId) {
            id
          }
        }
      GRAPHQL

      project = create(:project)
      company = project.client.company
      user = create(:membership, company:).user
      assignment = create(:assignment, project:, user:)
      create(:work_week, assignment:, actual_hours: 0)

      result = execute_graphql(query, user:, company:, variables: { projectId: project.id })

      assert_nil result['errors']
      assert_equal project.id.to_s, result['data']['deleteProject']['id']
      assert_raises(ActiveRecord::RecordNotFound) { project.reload }
    end
  end
end
