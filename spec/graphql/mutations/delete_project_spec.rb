# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mutations::DeleteProject do

  context "resolve" do
    it 'resolves to an error when a project cannot be destroyed' do
      query_string = <<-GRAPHQL
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
      assignment = create(:assignment, project: project, user: user)
      create(:work_week, assignment: assignment, actual_hours: 5)

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: company
        },
        variables: {
          projectId: project.id
        }
      )

      expect(result["errors"].first["message"]).to eq("Cannot delete a project that has assignments with hours recorded. Try archiving the project instead.")
      expect(project.reload.persisted?).to eq(true)
      post_result = result["data"]["deleteProject"]
      expect(post_result["id"]).to eq(project.id.to_s)
      expect(post_result["status"]).to eq(Project::CONFIRMED)
    end

    it "destroys a project that can be destroyed" do
      query_string = <<-GRAPHQL
        mutation($projectId: ID!) {
          deleteProject(projectId: $projectId) {
            id
          }
        }
      GRAPHQL

      project = create(:project)
      company = project.client.company
      user = create(:membership, company:).user
      assignment = create(:assignment, project: project, user: user)
      create(:work_week, assignment: assignment, actual_hours: 0)

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: company
        },
        variables: {
          projectId: project.id
        }
      )

      post_result = result["data"]["deleteProject"]
      expect(result["errors"]).to be_nil
      expect(post_result["id"]).to eq(project.id.to_s)
      expect { project.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
