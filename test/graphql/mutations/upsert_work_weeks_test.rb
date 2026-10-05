# frozen_string_literal: true

require 'test_helper'

module Mutations
  class UpsertWorkWeeksTest < ActiveSupport::TestCase
    QUERY = <<~GRAPHQL
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

    def assert_work_weeks_match(expected, actual)
      actual.each do |result|
        work_week = expected.detect { |uww| uww[:cweek] == result['cweek'] && uww[:year] == result['year'] }

        assert_predicate work_week, :present?
        assert_equal work_week[:actualHours], result['actualHours']
        assert_equal work_week[:estimatedHours], result['estimatedHours']
      end
    end

    def past_work_weeks(assignment, count: 5)
      Array.new(count) do |i|
        date = Time.zone.today - i.weeks
        create(:work_week, :blank, assignment:, cweek: date.cweek, year: date.cwyear)
      end
    end

    def updates_for(work_weeks)
      work_weeks.map.with_index do |week, i|
        { cweek: week.cweek, year: week.year, actualHours: i * 5, estimatedHours: i * 6 }
      end
    end

    test 'allows a user to zero out estimated hours' do
      user = create(:user)
      assignment = assignment_for_user(user:)
      today = Time.zone.today
      work_week = create(:work_week, :blank, assignment:, cweek: [1, today.cweek - 1].max, year: today.cwyear - 1)

      result = execute_graphql(
        QUERY,
        user:,
        company: assignment.company,
        variables: {
          assignmentId: assignment.id,
          workWeeks: [{ cweek: work_week.cweek, year: work_week.year, actualHours: 5, estimatedHours: 0 }],
        },
      )

      post_result = result['data']['upsertWorkWeeks']['workWeeks'].first

      assert_equal 5, post_result['actualHours']
      assert_equal 0, post_result['estimatedHours']
    end

    test 'updates the work weeks with valid params' do
      user = create(:user)
      assignment = assignment_for_user(user:)
      updated_work_weeks = updates_for(past_work_weeks(assignment))

      result = execute_graphql(
        QUERY,
        user:,
        company: assignment.company,
        variables: { assignmentId: assignment.id, workWeeks: updated_work_weeks },
      )

      assert_work_weeks_match(updated_work_weeks, result['data']['upsertWorkWeeks']['workWeeks'])
    end

    test 'updates the work weeks for TBD assignments' do
      company = create(:company)
      assignment = tbd_assignment_for_company(company:)
      updated_work_weeks = updates_for(past_work_weeks(assignment))

      result = execute_graphql(
        QUERY,
        user: company.users.first,
        company:,
        variables: { assignmentId: assignment.id, workWeeks: updated_work_weeks },
      )

      assert_work_weeks_match(updated_work_weeks, result['data']['upsertWorkWeeks']['workWeeks'])
    end

    test 'deletes future work weeks when estimatedHours is null or 0' do
      company = create(:company)
      assignment = tbd_assignment_for_company(company:)

      # avoid flakes from real time passing during the test
      Timecop.freeze(Time.zone.today.at_middle_of_day) do
        work_weeks = Array.new(5) do |i|
          date = Time.zone.today + i.weeks
          create(:work_week, :blank, assignment:, cweek: date.cweek, year: date.cwyear)
        end
        updated_work_weeks = updates_for(work_weeks)

        # current week with a nil estimate: kept
        updated_work_weeks.first[:estimatedHours] = nil
        # future week with a 0 estimate: deleted
        updated_work_weeks.second[:estimatedHours] = 0
        # future week with a nil estimate: deleted
        updated_work_weeks.third[:estimatedHours] = nil

        result = execute_graphql(
          QUERY,
          user: company.users.first,
          company:,
          variables: { assignmentId: assignment.id, workWeeks: updated_work_weeks },
        )

        post_result = result['data']['upsertWorkWeeks']['workWeeks']

        assert_equal 3, post_result.length
        assert_equal [updated_work_weeks[0][:cweek], updated_work_weeks[3][:cweek], updated_work_weeks[4][:cweek]],
                     post_result.pluck('cweek')
        assert_equal 0, post_result.find { |pr| pr['cweek'] == updated_work_weeks[0][:cweek] }['estimatedHours']
      end
    end

    test 'fails if the assignment is not found' do
      user = create(:user)
      work_week = create(:work_week, :blank)

      result = execute_graphql(
        QUERY,
        user:,
        variables: {
          assignmentId: -1,
          workWeeks: [{ cweek: work_week.cweek, year: work_week.year, actualHours: 5, estimatedHours: 6 }],
        },
      )

      assert_equal 1, result['errors'].length
      assert_equal 'Assignment not found', result['errors'].first['message']
    end

    test 'fails if the current user is not a member of the assignment company' do
      assignment = assignment_for_user(user: create(:user))
      random_user = create(:user)

      result = execute_graphql(
        QUERY,
        user: random_user,
        variables: {
          assignmentId: assignment.id,
          workWeeks: [{ cweek: 15, year: 2024, actualHours: 5, estimatedHours: 5 }],
        },
      )

      assert_equal 1, result['errors'].length
      assert_equal 'Assignment not found', result['errors'].first['message']
    end

    test 'succeeds for past work weeks when the user is not an active member of the company' do
      work_week = create(:work_week, :blank)
      work_week.user.memberships.update_all(status: Membership::INACTIVE) # rubocop:disable Rails/SkipsModelValidations

      result = execute_graphql(
        QUERY,
        user: work_week.user,
        company: work_week.company,
        variables: {
          assignmentId: work_week.assignment_id,
          workWeeks: [{ cweek: 14, year: 2023, actualHours: 5, estimatedHours: 12 }],
        },
      )

      post_result = result['data']['upsertWorkWeeks']['workWeeks']

      assert_equal 2, post_result.length
      assert_equal [0, 5], post_result.pluck('actualHours').sort
      assert_equal 5, post_result.find { |ww| ww['cweek'] == 14 && ww['year'] == 2023 }['actualHours']
    end

    test 'fails for future work weeks when the user is not an active member of the company' do
      date = 1.month.from_now.to_date
      work_week = create(:work_week, :blank, cweek: date.cweek, year: date.cwyear)
      work_week.user.memberships.update_all(status: Membership::INACTIVE) # rubocop:disable Rails/SkipsModelValidations

      result = execute_graphql(
        QUERY,
        user: work_week.user,
        company: work_week.company,
        variables: {
          assignmentId: work_week.assignment_id,
          workWeeks: [{ cweek: work_week.cweek, year: work_week.year, actualHours: 5, estimatedHours: 12 }],
        },
      )

      post_result = result['data']['upsertWorkWeeks']['workWeeks']

      assert_equal 1, post_result.length
      assert_equal [0], post_result.pluck('actualHours')
      assert_equal 1, result['errors'].length
      assert_equal 'Unable to update 1 future work week(s) for an inactive user', result['errors'].first['message']
    end
  end
end
