# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mutations::UpsertWorkWeek do

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

    it "updates the work week on a tbd assignment" do
      query_string = <<-GRAPHQL
        mutation($assignmentId: ID!, $cweek: Int!, $year: Int!, $actualHours: Int, $estimatedHours: Int) {
          upsertWorkWeek(assignmentId: $assignmentId, cweek: $cweek, year: $year, actualHours: $actualHours, estimatedHours: $estimatedHours) {
            actualHours
            estimatedHours
          }
        }
      GRAPHQL

      company = create(:company)
      assignment = tbd_assignment_for_company(company:)
      user = company.users.first
      work_week = create(:work_week, :blank, assignment:)

      expect(work_week.estimated_hours).to eq(0)
      expect(work_week.actual_hours).to eq(0)

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
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

    it "deletes a future work week when passed a null or 0 value for estimatedHours" do
      query_string = <<-GRAPHQL
        mutation($assignmentId: ID!, $cweek: Int!, $year: Int!, $actualHours: Int, $estimatedHours: Int) {
          upsertWorkWeek(assignmentId: $assignmentId, cweek: $cweek, year: $year, actualHours: $actualHours, estimatedHours: $estimatedHours) {
            actualHours
            estimatedHours
          }
        }
      GRAPHQL

      company = create(:company)
      assignment = tbd_assignment_for_company(company:)
      user = company.users.first
      work_week = create(:work_week,
        cweek: (Date.today + 1.month).cweek,
        year: (Date.today + 1.month).year,
        estimated_hours: 10,
        actual_hours: 0,
        assignment:
      )

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: work_week.company
        },
        variables: {
          assignmentId: work_week.assignment_id,
          cweek: work_week.cweek,
          year: work_week.year,
          actualHours: 0,
          estimatedHours: nil
        }
      )

      post_result = result["data"]["upsertWorkWeek"]
      expect(post_result["actualHours"]).to eq(0)
      expect(post_result["estimatedHours"]).to eq(10)
      expect {
        work_week.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not delete a past work week when passed a null or 0 value for estimatedHours if there are actualHours" do
      query_string = <<-GRAPHQL
        mutation($assignmentId: ID!, $cweek: Int!, $year: Int!, $actualHours: Int, $estimatedHours: Int) {
          upsertWorkWeek(assignmentId: $assignmentId, cweek: $cweek, year: $year, actualHours: $actualHours, estimatedHours: $estimatedHours) {
            actualHours
            estimatedHours
          }
        }
      GRAPHQL

      company = create(:company)
      assignment = tbd_assignment_for_company(company:)
      user = company.users.first

      past_date = Date.today - 2.months
      work_week = create(:work_week,
        cweek: past_date.cweek,
        year: past_date.year,
        estimated_hours: 10,
        actual_hours: 10,
        assignment:
      )

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: work_week.company
        },
        variables: {
          assignmentId: work_week.assignment_id,
          cweek: work_week.cweek,
          year: work_week.year,
          estimatedHours: nil,
          actualHours: 10
        }
      )

      post_result = result["data"]["upsertWorkWeek"]
      expect(post_result["actualHours"]).to eq(10)
      expect(post_result["estimatedHours"]).to eq(0)
      expect {
        work_week.reload
      }.to_not raise_error
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
          year: today.cwyear,
          estimatedHours: 15
        }
      )

      post_result = result["data"]["upsertWorkWeek"]
      expect(post_result["cweek"]).to eq(today.cweek)
      expect(post_result["year"]).to eq(today.cwyear)
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
