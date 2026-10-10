# frozen_string_literal: true

require 'test_helper'

module Timeline
  class PeopleSortTest < ActiveSupport::TestCase
    test 'defaults to least covered and ignores unknown values' do
      [nil, '', 'name_asc', 'alpha_sideways'].each do |value|
        assert_equal 'least_covered', PeopleSort.parse(value).to_param
      end
    end

    test 'cycles least covered, most covered, alpha ascending, alpha descending' do
      modes = PeopleSort::MODES.map { PeopleSort.parse(it) }

      assert_equal %w[most_covered alpha_asc alpha_desc least_covered], modes.map(&:next)
      assert_equal ['least covered', 'most covered', 'alpha', 'alpha'], modes.map(&:label)
      assert_equal [false, true, false, true], modes.map(&:desc?)
    end

    test 'counts estimated hours from the current ISO week on, across a year boundary' do
      travel_to Date.new(2027, 1, 1) # Friday of ISO week 53, 2026
      assignment = assignment_for_user(user: create(:membership).user)
      { [2026, 52] => 99, [2026, 53] => 5, [2027, 1] => 7, [2027, 2] => 11 }.each do |(year, cweek), hours|
        create(:work_week, assignment:, year:, cweek:, estimated_hours: hours, actual_hours: 0)
      end

      assert_equal({ assignment.user_id => 23 }, PeopleSort.future_hours(Assignment.all))
    end

    test 'only counts the given assignments' do
      user = create(:membership).user
      counted = assignment_for_user(user:)
      ignored = assignment_for_user(user:)
      create(:work_week, assignment: counted, estimated_hours: 4, actual_hours: 0)
      create(:work_week, assignment: ignored, estimated_hours: 6, actual_hours: 0)

      assert_equal({ user.id => 4 }, PeopleSort.future_hours(Assignment.where(id: counted)))
    end

    test 'sorts by future hours, then name, putting people without hours first when least covered' do
      company = create(:company)
      busy, idle, light = %w[Busy Idle Light].map { create(:membership, company:, user: build(:user, name: it, current_company: company)).user }
      light_assignment = assignment_for_user(user: light)
      busy_assignment = assignment_for_user(user: busy)
      create(:work_week, assignment: light_assignment, estimated_hours: 5, actual_hours: 0)
      create(:work_week, assignment: busy_assignment, estimated_hours: 30, actual_hours: 0)
      people = [busy, idle, light]

      assert_equal %w[Idle Light Busy], sorted_names('least_covered', people)
      assert_equal %w[Busy Light Idle], sorted_names('most_covered', people)
    end

    test 'sorts alphabetically, ignoring case' do
      people = %w[bea Cal adam].map { User.new(name: it) }

      assert_equal %w[adam bea Cal], sorted_names('alpha_asc', people)
      assert_equal %w[Cal bea adam], sorted_names('alpha_desc', people)
    end

    private

    def sorted_names(mode, people)
      PeopleSort.parse(mode).apply(people, assignments: Assignment.all).map(&:name)
    end
  end
end
