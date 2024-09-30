# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mutations::DeleteAssignment do

  context "resolve" do
    it "destroys an unassigned (TBD) assignment" do
      query_string = <<-GRAPHQL
        mutation($assignmentId: ID!) {
          deleteAssignment(assignmentId: $assignmentId) {
            id
            status
          }
        }
      GRAPHQL

      project = create(:project)
      assignment = create(:assignment, :unassigned, project:)
      company = project.company
      user = company.users.first

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: company
        },
        variables: {
          assignmentId: assignment.id
        }
      )

      post_result = result["data"]["deleteAssignment"]
      expect(result["errors"]).to be_nil
      expect(post_result["id"]).to eq(assignment.id.to_s)
      expect(post_result["status"]).to eq(Assignment::PROPOSED)
      expect { assignment.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns an error when a deletion is attempted on a non-TBD assignment" do
      query_string = <<-GRAPHQL
        mutation($assignmentId: ID!) {
          deleteAssignment(assignmentId: $assignmentId) {
            id
            status
          }
        }
      GRAPHQL

      assignment = create(:assignment)
      company = assignment.project.company
      user = company.users.first

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: company
        },
        variables: {
          assignmentId: assignment.id
        }
      )

      post_result = result["data"]["deleteAssignment"]
      expect(result["errors"].first["message"]).to eq("Cannot delete an assignment that's assigned. Try archiving the assignment instead.")
      assignment.reload
      expect(post_result["id"]).to eq(assignment.id.to_s)
      expect(post_result["status"]).to eq(Assignment::ACTIVE)
    end
  end
end
