# frozen_string_literal: true

require 'test_helper'

class HoursApprovalTest < ActiveSupport::TestCase
  setup do
    travel_to Date.new(2026, 10, 8)
    @user = create(:membership).user
    @this_week = Date.new(2026, 10, 5)
  end

  test "records each assignment's plan for the week as actual hours" do
    planned = assignment_for_user(user: @user)
    create(:work_week, assignment: planned, cweek: @this_week.cweek, year: 2026, estimated_hours: 30, actual_hours: 0)
    scheduled = assignment_for_user(user: @user)
    scheduled.update!(starts_on: Date.new(2026, 9, 1), ends_on: Date.new(2026, 12, 31), estimated_weekly_hours: 10)
    idle = assignment_for_user(user: @user)

    assert HoursApproval.new(assignments: [planned, scheduled, idle], monday: @this_week).save

    assert_equal [30, 30], hours(planned)
    assert_equal [10, 10], hours(scheduled)
    assert_empty idle.work_weeks
  end

  test 'refuses future weeks and weeks that already have actual hours' do
    assignment = assignment_for_user(user: @user)
    create(:work_week, assignment:, cweek: 42, year: 2026, estimated_hours: 20, actual_hours: 0)
    create(:work_week, assignment:, cweek: @this_week.cweek, year: 2026, estimated_hours: 30, actual_hours: 12)

    assert_not HoursApproval.new(assignments: [assignment], monday: Date.new(2026, 10, 12)).save
    assert_not HoursApproval.new(assignments: [assignment], monday: @this_week).save
    assert_equal [30, 12], hours(assignment)
  end

  private

  def hours(assignment, week: @this_week)
    work_week = assignment.work_weeks.find_by!(cweek: week.cweek, year: week.cwyear)
    [work_week.estimated_hours, work_week.actual_hours]
  end
end
