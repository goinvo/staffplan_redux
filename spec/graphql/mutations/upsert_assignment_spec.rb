# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mutations::UpsertAssignment do

  context "resolve" do
    it "creates a new assignment proposed unassigned assignment" do
      query_string = <<-GRAPHQL
        mutation($projectId: ID!, $userId: ID, $status: String!) {
          upsertAssignment(projectId: $projectId, userId: $userId, status: $status) {
            id
            project {
              id
            }
            assignedUser {
              id
            }  
            status
            startsOn
            endsOn
          }
        }
      GRAPHQL

      user = create(:user)
      project = create(:project, company: user.current_company)

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: user.current_company
        },
        variables: {
          projectId: project.id,
          status: Assignment::PROPOSED
        }
      )

      post_result = result["data"]["upsertAssignment"]
      expect(result["errors"]).to be_nil
      expect(post_result["project"]["id"]).to eq(project.id.to_s)
      expect(post_result["assignedUser"]).to be_nil
      expect(post_result["status"]).to eq(Assignment::PROPOSED)
      expect(post_result["startsOn"]).to be_nil
      expect(post_result["endsOn"]).to be_nil
    end

    it "creates a new assignment with valid params" do
      query_string = <<-GRAPHQL
        mutation($projectId: ID!, $userId: ID, $status: String!) {
          upsertAssignment(projectId: $projectId, userId: $userId, status: $status) {
            id
            project {
              id
            }
            assignedUser {
              id
            }  
            status
            startsOn
            endsOn
          }
        }
      GRAPHQL

      user = create(:user)
      project = create(:project, company: user.current_company)

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: user.current_company
        },
        variables: {
          projectId: project.id,
          userId: user.id,
          status: Assignment::PROPOSED
        }
      )

      post_result = result["data"]["upsertAssignment"]
      expect(result["errors"]).to be_nil
      expect(post_result["project"]["id"]).to eq(project.id.to_s)
      expect(post_result["assignedUser"]["id"]).to eq(user.id.to_s)
      expect(post_result["status"]).to eq(Assignment::PROPOSED)
      expect(post_result["startsOn"]).to be_nil
      expect(post_result["endsOn"]).to be_nil
    end

    it "updates the assignment with valid params" do
      query_string = <<-GRAPHQL
        mutation($id: ID, $projectId: ID!, $userId: ID, $status: String!, $estimatedWeeklyHours: Int, $startsOn: ISO8601Date, $endsOn: ISO8601Date) {
          upsertAssignment(id: $id, projectId: $projectId, userId: $userId, status: $status, estimatedWeeklyHours: $estimatedWeeklyHours, startsOn: $startsOn, endsOn: $endsOn) {
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

      user = create(:user)
      assignment = assignment_for_user(user:, status: Assignment::PROPOSED)

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: user.current_company
        },
        variables: {
          id: assignment.id,
          projectId: assignment.project_id,
          userId: assignment.user_id,
          status: Assignment::ACTIVE,
          estimatedWeeklyHours: estimated_weekly_hours = 40,
          startsOn: starts_on = 2.weeks.from_now.to_date.iso8601,
          endsOn: ends_on = 10.weeks.from_now.to_date.iso8601
        }
      )

      post_result = result["data"]["upsertAssignment"]
      expect(result["errors"]).to be_nil
      expect(post_result["status"]).to eq(Assignment::ACTIVE)
      expect(post_result["estimatedWeeklyHours"]).to eq(estimated_weekly_hours)
      expect(post_result["startsOn"]).to eq(starts_on.to_s)
      expect(post_result["endsOn"]).to eq(ends_on.to_s)
    end

    it "renders validation errors" do
      query_string = <<-GRAPHQL
        mutation($id: ID, $projectId: ID!, $userId: ID, $status: String!) {
          upsertAssignment(id: $id, projectId: $projectId, userId: $userId, status: $status) {
            id
            project {
              id
            }
            assignedUser {
              id
            }  
            status
            startsOn
            endsOn
          }
        }
      GRAPHQL

      user = create(:user)
      assignment = assignment_for_user(user:)

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: user.current_company
        },
        variables: {
          id: assignment.id,
          projectId: create(:project).id,
          userId: assignment.user_id,
          status: Assignment::ACTIVE,
        }
      )

      post_result = result["errors"]
      expect(post_result.length).to eq(1)
      expect(post_result.first["message"]).to eq("Project and user must belong to the same company")
    end

    it "raises a 404 if given an assignment id that doesn't exist on the company" do
      query_string = <<-GRAPHQL
        mutation($id: ID, $projectId: ID!, $userId: ID, $status: String!) {
          upsertAssignment(id: $id, projectId: $projectId, userId: $userId, status: $status) {
            id
            project {
              id
            }
            assignedUser {
              id
            }  
            status
            startsOn
            endsOn
          }
        }
      GRAPHQL

      user = create(:user)
      assignment = assignment_for_user(user:)

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: user.current_company
        },
        variables: {
          id: assignment_for_user(user: create(:user)).id,
          projectId: assignment.project_id,
          userId: assignment.user_id,
          status: Assignment::ACTIVE,
        }
      )

      post_result = result["errors"]
      expect(post_result.first["message"]).to eq("Assignment not found")
    end
  end
end