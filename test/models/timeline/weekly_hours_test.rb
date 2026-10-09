# frozen_string_literal: true

require 'test_helper'

module Timeline
  class WeeklyHoursTest < ActiveSupport::TestCase
    setup do
      travel_to Date.new(2026, 10, 8)
      @user = create(:membership).user
      @window = Window.from_param(nil)
      @last_week, @this_week, @next_week = @window.weeks.first(3)
    end

    test 'sums actual, estimated and proposed hours per week' do
      active = assignment_for_user(user: @user)
      proposed = assignment_for_user(user: @user, status: Assignment::PROPOSED)
      work_week(active, @this_week, estimated: 20, actual: 15)
      work_week(proposed, @this_week, estimated: 10, actual: 5)
      work_week(active, @next_week, estimated: 30)

      hours = WeeklyHours.new(assignments: [active, proposed], window: @window)

      assert_equal WeeklyHours::Hours.new(actual: 20, estimated: 30, proposed: 10), hours.for(@this_week)
      assert_equal WeeklyHours::Hours.new(actual: 0, estimated: 30, proposed: 0), hours.for(@next_week)
      assert_equal WeeklyHours::Hours.new(actual: 0, estimated: 0, proposed: 0), hours.for(@last_week)
      assert_equal 30, hours.max
    end

    test 'shows actual hours for weeks that have them, otherwise estimates' do
      assignment = assignment_for_user(user: @user)
      work_week(assignment, @this_week, estimated: 40, actual: 12)
      work_week(assignment, @next_week, estimated: 40)

      hours = WeeklyHours.new(assignments: [assignment], window: @window)

      assert_equal 12, hours.for(@this_week).total
      assert_equal 40, hours.for(@next_week).total
    end

    test 'ignores work weeks outside the window and for other assignments' do
      assignment = assignment_for_user(user: @user)
      other = assignment_for_user(user: @user)
      monday = @window.shift(-1)
      create(:work_week, assignment:, cweek: monday.cweek, year: monday.cwyear, estimated_hours: 99, actual_hours: 99)
      work_week(other, @this_week, estimated: 50)

      hours = WeeklyHours.new(assignments: [assignment], window: @window)

      assert_equal 0, hours.max
    end

    test 'matches work weeks by ISO week year across a year boundary' do
      assignment = assignment_for_user(user: @user)
      create(:work_week, assignment:, cweek: 1, year: 2027, estimated_hours: 8, actual_hours: 0)
      create(:work_week, assignment:, cweek: 1, year: 2026, estimated_hours: 99, actual_hours: 0)

      hours = WeeklyHours.new(assignments: [assignment], window: Window.new(start: Date.new(2026, 12, 21)))
      first_week_of_2027 = hours.window.weeks.third

      assert_equal 8, hours.for(first_week_of_2027).estimated
      assert_equal 8, hours.max
    end

    test 'fills weeks without a work week from the weekly estimate within the assignment dates' do
      assignment = assignment_for_user(user: @user, status: Assignment::PROPOSED)
      assignment.update!(starts_on: @this_week.monday, ends_on: @this_week.monday + 2.weeks, estimated_weekly_hours: 6)
      work_week(assignment, @next_week, estimated: 3)

      hours = WeeklyHours.new(assignments: [assignment], window: @window)

      assert_equal([0, 6, 3, 0], @window.weeks.first(4).map { hours.for(it).estimated })
      assert_equal([0, 6, 3, 0], @window.weeks.first(4).map { hours.for(it).proposed })
    end

    test 'keeps applying the weekly estimate when the assignment has no end date' do
      assignment = assignment_for_user(user: @user)
      assignment.update!(starts_on: @next_week.monday, estimated_weekly_hours: 4)

      hours = WeeklyHours.new(assignments: [assignment], window: @window)

      assert_equal 0, hours.for(@this_week).estimated
      assert_equal 4, hours.for(@window.weeks.last).estimated
    end

    test 'returns the saved work week for a cell, or an unsaved one with the weekly estimate' do
      assignment = assignment_for_user(user: @user)
      assignment.update!(starts_on: @next_week.monday, estimated_weekly_hours: 8)
      saved = work_week(assignment, @this_week, estimated: 0)

      hours = WeeklyHours.new(assignments: [assignment], window: @window)

      assert_equal saved, hours.work_week(assignment, @this_week)

      cell = hours.work_week(assignment, @next_week)

      assert_predicate cell, :new_record?
      assert_equal [8, 0, @next_week.cweek, @next_week.year], [cell.estimated_hours, cell.actual_hours, cell.cweek, cell.year]
      assert_equal 0, hours.work_week(assignment, @last_week).estimated_hours
    end

    private

    def work_week(assignment, week, estimated:, actual: 0)
      create(:work_week, assignment:, cweek: week.cweek, year: week.year, estimated_hours: estimated, actual_hours: actual)
    end
  end
end
