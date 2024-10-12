# frozen_string_literal: true

require "rails_helper"

RSpec.describe Mutations::UpsertWorkWeeks do

  context "when updating work weeks" do
    it "updates the work weeks with valid params" do
      query_string = <<-GRAPHQL
        mutation($assignmentId: ID!, $workWeeks: [WorkWeeksInputObject!]!) {
          upsertWorkWeeks(assignmentId: $assignmentId, workWeeks: $workWeeks) {
            workWeeks {
              cweek
              year
              actualHours
              estimatedHours
            }          
          }
        }
      GRAPHQL

      user = create(:user)
      assignment = assignment_for_user(user:)
      work_weeks = 5.times.map do |i|
        date = Date.today - i.weeks
        create(:work_week, :blank, assignment:, cweek: date.cweek, year: date.year)
      end

      updated_work_weeks = work_weeks.map.with_index do |week, i|
        {
          cweek: week.cweek,
          year: week.year,
          actualHours: i * 5,
          estimatedHours: i * 6
        }
      end

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: assignment.company
        },
        variables: {
          assignmentId: assignment.id,
          workWeeks: updated_work_weeks
        }
      )

      post_result = result["data"]["upsertWorkWeeks"]["workWeeks"]

      post_result.each do |result|
        work_week = updated_work_weeks.detect do |uww|
          uww[:cweek] == result["cweek"] && uww[:year] == result["year"]
        end

        expect(work_week).to be_present
        expect(work_week[:actualHours]).to eq(result["actualHours"])
        expect(work_week[:estimatedHours]).to eq(result["estimatedHours"])
      end
    end

    it "updates the work weeks for TBD assigments" do
      query_string = <<-GRAPHQL
        mutation($assignmentId: ID!, $workWeeks: [WorkWeeksInputObject!]!) {
          upsertWorkWeeks(assignmentId: $assignmentId, workWeeks: $workWeeks) {
            workWeeks {
              cweek
              year
              actualHours
              estimatedHours
            }          
          }
        }
      GRAPHQL

      company = create(:company)
      assignment = tbd_assignment_for_company(company:)
      user = company.users.first
      work_weeks = 5.times.map do |i|
        date = Date.today - i.weeks
        create(:work_week, :blank, assignment:, cweek: date.cweek, year: date.year)
      end

      updated_work_weeks = work_weeks.map.with_index do |week, i|
        {
          cweek: week.cweek,
          year: week.year,
          actualHours: i * 5,
          estimatedHours: i * 6
        }
      end

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: company
        },
        variables: {
          assignmentId: assignment.id,
          workWeeks: updated_work_weeks
        }
      )

      post_result = result["data"]["upsertWorkWeeks"]["workWeeks"]

      post_result.each do |result|
        work_week = updated_work_weeks.detect do |uww|
          uww[:cweek] == result["cweek"] && uww[:year] == result["year"]
        end

        expect(work_week).to be_present
        expect(work_week[:actualHours]).to eq(result["actualHours"])
        expect(work_week[:estimatedHours]).to eq(result["estimatedHours"])
      end
    end

    it "deletes future work weeks when passed null or empty values for estimatedHours" do
      query_string = <<-GRAPHQL
        mutation($assignmentId: ID!, $workWeeks: [WorkWeeksInputObject!]!) {
          upsertWorkWeeks(assignmentId: $assignmentId, workWeeks: $workWeeks) {
            workWeeks {
              cweek
              year
              actualHours
              estimatedHours
            }          
          }
        }
      GRAPHQL

      company = create(:company)
      assignment = tbd_assignment_for_company(company:)
      user = company.users.first

      # to avoid any IRL time related test flakes
      Timecop.freeze(Date.today.at_middle_of_day) do
        work_weeks = 5.times.map do |i|
          date = Date.today + i.weeks
          create(:work_week, :blank, assignment:, cweek: date.cweek, year: date.year)
        end

        updated_work_weeks = work_weeks.map.with_index do |week, i|
          {
            cweek: week.cweek,
            year: week.year,
            actualHours: i * 5,
            estimatedHours: i * 6
          }
        end

        # set the estimated hours to nil for the first work week, should not be deleted
        updated_work_weeks.first[:estimatedHours] = nil

        # set the estimated hours to 0 for the second work week, should be deleted
        updated_work_weeks.second[:estimatedHours] = 0

        # set the estimated hours to nil for the first work week, should be deleted
        updated_work_weeks.third[:estimatedHours] = nil

        result = StaffplanReduxSchema.execute(
          query_string,
          context: {
            current_user: user,
            current_company: company
          },
          variables: {
            assignmentId: assignment.id,
            workWeeks: updated_work_weeks
          }
        )

        post_result = result["data"]["upsertWorkWeeks"]["workWeeks"]
        expect(post_result.length).to eq(3)
        expect(post_result.map { |pr| pr["cweek"] }).to eq([
          updated_work_weeks[0][:cweek], updated_work_weeks[3][:cweek], updated_work_weeks[4][:cweek]
        ])
      end
    end

    it "fails if the assignment is not found" do
      query_string = <<-GRAPHQL
        mutation($assignmentId: ID!, $workWeeks: [WorkWeeksInputObject!]!) {
          upsertWorkWeeks(assignmentId: $assignmentId, workWeeks: $workWeeks) {
            workWeeks {
              cweek
              year
              actualHours
              estimatedHours
            }          
          }
        }
      GRAPHQL

      user = create(:user)
      work_weeks = Array(create(:work_week, :blank)).map do |ww|
        {
          cweek: ww.cweek,
          year: ww.year,
          actualHours: 5,
          estimatedHours: 6
        }
      end

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: user,
          current_company: user.current_company
        },
        variables: {
          assignmentId: -1,
          workWeeks: work_weeks
        }
      )

      post_result = result["errors"]
      expect(post_result.length).to eq(1)
      expect(post_result.first["message"]).to eq("Assignment not found")
    end

    it "fails if the current_user is not a member of the company that the assignment belongs to" do
      query_string = <<-GRAPHQL
        mutation($assignmentId: ID!, $workWeeks: [WorkWeeksInputObject!]!) {
          upsertWorkWeeks(assignmentId: $assignmentId, workWeeks: $workWeeks) {
            workWeeks {
              actualHours
              estimatedHours
            }
          }
        }
      GRAPHQL

      user = create(:user)
      assignment = assignment_for_user(user:)
      random_user = create(:user)

      result = StaffplanReduxSchema.execute(
        query_string,
        context: {
          current_user: random_user,
          current_company: random_user.current_company
        },
        variables: {
          assignmentId: assignment.id,
          workWeeks: [{
            cweek: 15,
            year: 2024,
            actualHours: 5,
            estimatedHours: 5
          }]
        }
      )

      post_result = result["errors"]
      expect(post_result.length).to eq(1)
      expect(post_result.first["message"]).to eq("Assignment not found")
    end

    it "fails if the user is not an active member of the company" do
      query_string = <<-GRAPHQL
        mutation($assignmentId: ID!, $workWeeks: [WorkWeeksInputObject!]!) {
          upsertWorkWeeks(assignmentId: $assignmentId, workWeeks: $workWeeks) {
            workWeeks {
              actualHours
              estimatedHours
            }
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
          workWeeks: [{
            cweek: 14,
            year: 2023,
            actualHours: 5,
            estimatedHours: 12
          }]
        }
      )

      post_result = result["errors"]
      expect(post_result.length).to eq(1)
      expect(post_result.first["message"]).to eq("User is not an active member of the company")
    end
  end
end
