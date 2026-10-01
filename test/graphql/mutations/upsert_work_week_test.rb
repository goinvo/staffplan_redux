# frozen_string_literal: true

require 'test_helper'

module Mutations
  class UpsertWorkWeekTest < ActiveSupport::TestCase
    QUERY = <<~GRAPHQL
      mutation($assignmentId: ID!, $cweek: Int!, $year: Int!, $actualHours: Int, $estimatedHours: Int) {
        upsertWorkWeek(assignmentId: $assignmentId, cweek: $cweek, year: $year, actualHours: $actualHours, estimatedHours: $estimatedHours) {
          cweek
          year
          actualHours
          estimatedHours
        }
      }
    GRAPHQL

    def work_week_variables(work_week, **extra)
      { assignmentId: work_week.assignment_id, cweek: work_week.cweek, year: work_week.year, **extra }
    end

    test 'updates the work week with valid params' do
      user = create(:user)
      work_week = create(:work_week, :blank, assignment: assignment_for_user(user:))

      assert_equal 0, work_week.estimated_hours
      assert_equal 0, work_week.actual_hours

      result = execute_graphql(
        QUERY,
        user: work_week.user,
        company: work_week.company,
        variables: work_week_variables(work_week, actualHours: 10, estimatedHours: 20),
      )

      post_result = result['data']['upsertWorkWeek']

      assert_equal 10, post_result['actualHours']
      assert_equal 20, post_result['estimatedHours']
    end

    test 'updates the work week on a TBD assignment' do
      company = create(:company)
      work_week = create(:work_week, :blank, assignment: tbd_assignment_for_company(company:))

      assert_equal 0, work_week.estimated_hours
      assert_equal 0, work_week.actual_hours

      result = execute_graphql(
        QUERY,
        user: company.users.first,
        company: work_week.company,
        variables: work_week_variables(work_week, actualHours: 10, estimatedHours: 20),
      )

      post_result = result['data']['upsertWorkWeek']

      assert_equal 10, post_result['actualHours']
      assert_equal 20, post_result['estimatedHours']
    end

    test 'deletes a future work week when estimatedHours is null or 0' do
      company = create(:company)
      future = Time.zone.today + 1.month
      work_week = create(
        :work_week,
        cweek: future.cweek,
        year: future.cwyear,
        estimated_hours: 10,
        actual_hours: 0,
        assignment: tbd_assignment_for_company(company:),
      )

      result = execute_graphql(
        QUERY,
        user: company.users.first,
        company: work_week.company,
        variables: work_week_variables(work_week, actualHours: 0, estimatedHours: nil),
      )

      post_result = result['data']['upsertWorkWeek']

      assert_equal 0, post_result['actualHours']
      assert_equal 10, post_result['estimatedHours']
      assert_raises(ActiveRecord::RecordNotFound) { work_week.reload }
    end

    test 'keeps a past work week with actual hours when estimatedHours is null or 0' do
      company = create(:company)
      past = Time.zone.today - 2.months
      work_week = create(
        :work_week,
        cweek: past.cweek,
        year: past.cwyear,
        estimated_hours: 10,
        actual_hours: 10,
        assignment: tbd_assignment_for_company(company:),
      )

      result = execute_graphql(
        QUERY,
        user: company.users.first,
        company: work_week.company,
        variables: work_week_variables(work_week, estimatedHours: nil, actualHours: 10),
      )

      post_result = result['data']['upsertWorkWeek']

      assert_equal 10, post_result['actualHours']
      assert_equal 0, post_result['estimatedHours']
      assert_nothing_raised { work_week.reload }
    end

    test "fails if the assignment doesn't belong to the current company" do
      user = create(:user)
      work_week = create(:work_week, :blank, assignment: assignment_for_user(user:))
      other_work_week = create(:work_week, :blank, assignment: assignment_for_user(user: create(:user)))

      result = execute_graphql(
        QUERY,
        user: work_week.user,
        company: work_week.company,
        variables: work_week_variables(other_work_week),
      )

      assert_equal 1, result['errors'].length
      assert_equal 'WorkWeek not found', result['errors'].first['message']
    end

    test 'fails if the current user is not a member of the assignment company' do
      user = create(:user)
      work_week = create(:work_week, :blank, assignment: assignment_for_user(user:))
      random_user = create(:user)

      result = execute_graphql(QUERY, user: random_user, variables: work_week_variables(work_week))

      assert_equal 1, result['errors'].length
      assert_equal 'WorkWeek not found', result['errors'].first['message']
    end

    test 'fails for a future work week when the user is not an active member of the company' do
      date = 1.month.from_now.to_date
      work_week = create(:work_week, :blank, cweek: date.cweek, year: date.cwyear)
      work_week.user.memberships.update_all(status: Membership::INACTIVE) # rubocop:disable Rails/SkipsModelValidations

      result = execute_graphql(QUERY, user: work_week.user, company: work_week.company, variables: work_week_variables(work_week))

      assert_equal 1, result['errors'].length
      assert_equal 'Unable to edit future work weeks for inactive users', result['errors'].first['message']
    end

    test 'succeeds for a past work week when the user is not an active member of the company' do
      date = 1.month.ago.to_date
      work_week = create(:work_week, :blank, cweek: date.cweek, year: date.cwyear)
      work_week.user.memberships.update_all(status: Membership::INACTIVE) # rubocop:disable Rails/SkipsModelValidations

      result = execute_graphql(
        QUERY,
        user: work_week.user,
        company: work_week.company,
        variables: work_week_variables(work_week, actualHours: 5, estimatedHours: 5),
      )

      post_result = result['data']['upsertWorkWeek']

      assert_equal 5, post_result['actualHours']
      assert_equal 5, post_result['estimatedHours']
    end

    test 'creates a new work week on the assignment' do
      user = create(:user)
      assignment = assignment_for_user(user:)
      today = Time.zone.today

      assert_empty assignment.work_weeks

      result = execute_graphql(
        QUERY,
        user:,
        variables: { assignmentId: assignment.id, cweek: today.cweek, year: today.cwyear, estimatedHours: 15 },
      )

      post_result = result['data']['upsertWorkWeek']

      assert_equal today.cweek, post_result['cweek']
      assert_equal today.cwyear, post_result['year']
      assert_equal 0, post_result['actualHours']
      assert_equal 15, post_result['estimatedHours']
    end

    test "fails to create a work week on another company's assignment" do
      user = create(:user)
      work_week = create(:work_week, :blank, assignment: assignment_for_user(user:))
      membership = create(:membership)

      result = execute_graphql(
        QUERY,
        user: membership.user,
        company: membership.company,
        variables: work_week_variables(work_week, estimatedHours: 15),
      )

      assert_equal 1, result['errors'].count
      assert_equal 'WorkWeek not found', result['errors'].first['message']
    end
  end
end
