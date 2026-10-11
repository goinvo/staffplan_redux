# frozen_string_literal: true

require 'test_helper'

module Timeline
  class StaffSortTest < ActiveSupport::TestCase
    test 'defaults to ascending and ignores unknown values' do
      [nil, '', 'client_asc', 'people_sideways'].each do |value|
        assert_equal 'people_asc', StaffSort.parse(value).to_param
      end
    end

    test 'puts unassigned rows first, then sorts people by name' do
      assignments = [
        Assignment.new(id: 3, user: User.new(name: 'cy')),
        Assignment.new(id: 9),
        Assignment.new(id: 1, user: User.new(name: 'Ann')),
        Assignment.new(id: 4),
      ]

      assert_equal [4, 9, 1, 3], StaffSort.parse('people_asc').apply(assignments).map(&:id)
      assert_equal [4, 9, 3, 1], StaffSort.parse('people_desc').apply(assignments).map(&:id)
    end

    test 'flips direction on each click' do
      assert_equal 'people_desc', StaffSort.parse('people_asc').next_for('people')
      assert_equal 'people_asc', StaffSort.parse('people_desc').next_for('people')
    end
  end
end
