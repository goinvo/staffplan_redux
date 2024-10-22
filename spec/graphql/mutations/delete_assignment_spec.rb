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

    it "allows deletion on a non-TBD assignment with no hours recorded" do
      query_string = <<-GRAPHQL
        mutation($assignmentId: ID!) {
          deleteAssignment(assignmentId: $assignmentId) {
            id
            status
          }
        }
      GRAPHQL

      assignment = create(:assignment)
      create(:work_week, assignment: assignment, actual_hours: 0)
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

      expect(result["errors"]).to eq(nil)
      expect {
        assignment.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
      post_result = result["data"]["deleteAssignment"]
      expect(post_result["id"]).to eq(assignment.id.to_s)
      expect(post_result["status"]).to eq(Assignment::ACTIVE)
    end

    it "blocks deletion on an assigned assignment with hours recorded" do
      query_string = <<-GRAPHQL
        mutation($assignmentId: ID!) {
          deleteAssignment(assignmentId: $assignmentId) {
            id
            status
          }
        }
      GRAPHQL

      assignment = create(:assignment)
      create(:work_week, assignment: assignment, actual_hours: 15)
      expect(assignment.reload.work_weeks.count).to eq(1)
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

      expect(result["errors"].first["message"]).to eq("Cannot delete an assignment that's assigned with hours recorded. Try archiving the assignment instead.")
      expect(assignment.reload.persisted?).to eq(true)
      post_result = result["data"]["deleteAssignment"]
      expect(post_result["id"]).to eq(assignment.id.to_s)
      expect(post_result["status"]).to eq(Assignment::ACTIVE)
    end
  end
end
