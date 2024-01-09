# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mutations::UpsertWorkWeek do

  # when the :work_weeks factory is used the user's current_company
  # is not the same as the one the project/assignment belongs to.
  def assignment_for_user(user:)
    client = create(:client, company: user.current_company)
    project = create(:project, client:)
    create(:assignment, user:, project:)
  end

  context "when updating a work week" do
    it "updates the work week with valid params" do
      query_string = <<-GRAPHQL
        mutation($assignmentId: ID!, $cweek: Int!, $year: Int!, $actualHours: Int, $estimatedHours: Int) {
          upsertWorkWeek(assignmentId: $assignmentId, cweek: $cweek, year: $year, actualHours: $actualHours, estimatedHours: $estimatedHours) {
            actualHours
            estimatedHours
          }
        }
      GRAPHQL

      user = create(:user)
      assignment = assignment_for_user(user:)
      work_week = create(:work_week, :blank, assignment:)

      expect(work_week.estimated_hours).to eq(0)
      expect(work_week.actual_hours).to eq(0)

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: work_week.user,
          current_company: work_week.company
        },
        variables: {
          assignmentId: work_week.assignment_id,
          cweek: work_week.cweek,
          year: work_week.year,
          actualHours: 10,
          estimatedHours: 20
        }
      )

      post_result = result["data"]["upsertWorkWeek"]
      expect(post_result["actualHours"]).to eq(10)
      expect(post_result["estimatedHours"]).to eq(20)
    end

    it "fails if the assignment is not found" do
      query_string = <<-GRAPHQL
        mutation($assignmentId: ID!, $cweek: Int!, $year: Int!) {
          upsertWorkWeek(assignmentId: $assignmentId, cweek: $cweek, year: $year) {
            actualHours
            estimatedHours
          }
        }
      GRAPHQL

      user = create(:user)
      assignment = assignment_for_user(user:)
      work_week = create(:work_week, :blank, assignment:)
      other_user = create(:user)
      other_assignment = assignment_for_user(user: other_user)
      other_work_week = create(:work_week, :blank, assignment: other_assignment)

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: work_week.user,
          current_company: work_week.company
        },
        variables: {
          assignmentId: other_work_week.assignment_id,
          cweek: other_work_week.cweek,
          year: other_work_week.year
        }
      )

      post_result = result["errors"]
      expect(post_result.length).to eq(1)
      expect(post_result.first["message"]).to eq("WorkWeek not found")
    end

    it "fails if the current_user is not a member of the company that the assignment belongs to" do
      query_string = <<-GRAPHQL
        mutation($assignmentId: ID!, $cweek: Int!, $year: Int!) {
          upsertWorkWeek(assignmentId: $assignmentId, cweek: $cweek, year: $year) {
            actualHours
            estimatedHours
          }
        }
      GRAPHQL

      user = create(:user)
      assignment = assignment_for_user(user:)
      work_week = create(:work_week, :blank, assignment:)
      random_user = create(:user)

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: random_user,
          current_company: random_user.current_company
        },
        variables: {
          assignmentId: work_week.assignment_id,
          cweek: work_week.cweek,
          year: work_week.year
        }
      )

      post_result = result["errors"]
      expect(post_result.length).to eq(1)
      expect(post_result.first["message"]).to eq("WorkWeek not found")
    end

    it "fails if the user is not an active member of the company" do
      query_string = <<-GRAPHQL
        mutation($assignmentId: ID!, $cweek: Int!, $year: Int!) {
          upsertWorkWeek(assignmentId: $assignmentId, cweek: $cweek, year: $year) {
            actualHours
            estimatedHours
          }
        }
      GRAPHQL

      work_week = create(:work_week, :blank)
      work_week.user.memberships.update_all(status: "inactive")

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: work_week.user,
          current_company: work_week.company
        },
        variables: {
          assignmentId: work_week.assignment_id,
          cweek: work_week.cweek,
          year: work_week.year
        }
      )

      post_result = result["errors"]
      expect(post_result.length).to eq(1)
      expect(post_result.first["message"]).to eq("User is not an active member of the company")
    end
  end

  context "when creating a new work week" do
    it "saves the work week to the assignment" do
      query_string = <<-GRAPHQL
        mutation($assignmentId: ID!, $cweek: Int!, $year: Int!, $actualHours: Int, $estimatedHours: Int) {
          upsertWorkWeek(assignmentId: $assignmentId, cweek: $cweek, year: $year, actualHours: $actualHours, estimatedHours: $estimatedHours) {
            cweek
            year
            actualHours
            estimatedHours
          }
        }
      GRAPHQL

      user = create(:user)
      assignment = assignment_for_user(user:)

      expect(assignment.work_weeks.length).to eq(0)

      today = Date.today

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: user.current_company
        },
        variables: {
          assignmentId: assignment.id,
          cweek: today.cweek,
          year: today.year,
          estimatedHours: 15
        }
      )

      post_result = result["data"]["upsertWorkWeek"]
      expect(post_result["cweek"]).to eq(today.cweek)
      expect(post_result["year"]).to eq(today.year)
      expect(post_result["actualHours"]).to eq(0)
      expect(post_result["estimatedHours"]).to eq(15)
    end

    it "fails if the assignment isn't on a project with the current company" do
      query_string = <<-GRAPHQL
        mutation($assignmentId: ID!, $cweek: Int!, $year: Int!, $actualHours: Int, $estimatedHours: Int) {
          upsertWorkWeek(assignmentId: $assignmentId, cweek: $cweek, year: $year, actualHours: $actualHours, estimatedHours: $estimatedHours) {
            actualHours
            estimatedHours
          }
        }
      GRAPHQL

      user = create(:user)
      assignment = assignment_for_user(user:)
      work_week = create(:work_week, :blank, assignment:)

      membership = create(:membership)

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: membership.user,
          current_company: membership.company
        },
        variables: {
          assignmentId: work_week.assignment_id,
          cweek: work_week.cweek,
          year: work_week.year,
          estimatedHours: 15
        }
      )

      post_result = result["errors"]
      expect(post_result.count).to eq(1)
      expect(post_result.first["message"]).to eq("WorkWeek not found")
    end
  end
end