# frozen_string_literal: true

require 'test_helper'

module Timeline
  class WindowTest < ActiveSupport::TestCase
    TODAY = Date.new(2026, 10, 8)

    test 'starts on the Monday of the week before the current week by default' do
      window = Window.from_param(nil, today: TODAY)

      assert_equal Date.new(2026, 9, 28), window.start
      assert_equal 1, window.current_week_index
    end

    test 'starts on the Monday of the week containing the start param' do
      assert_equal Date.new(2026, 11, 2), Window.from_param('2026-11-04', today: TODAY).start
      assert_equal Date.new(2026, 11, 2), Window.from_param('2026-11-02', today: TODAY).start
    end

    test 'falls back to the default for an invalid or out of range start param' do
      ['nope', '2026-13-01', '1999-12-27', '2200-01-05', ''].each do |value|
        assert_equal Date.new(2026, 9, 28), Window.from_param(value, today: TODAY).start, value
      end
    end

    test 'covers 52 consecutive Monday-start weeks' do
      weeks = Window.from_param(nil, today: TODAY).weeks

      assert_equal 52, weeks.size
      assert_equal (0...52).to_a, weeks.map(&:index)
      assert(weeks.all? { it.monday.monday? })
      assert_equal [7], weeks.each_cons(2).map { (it.last.monday - it.first.monday).to_i }.uniq
    end

    test 'uses ISO weeks across a 53-week year' do
      weeks = Window.new(start: Date.new(2026, 12, 21), today: TODAY).weeks

      assert_equal([[52, 2026], [53, 2026], [1, 2027]], weeks.first(3).map { [it.cweek, it.year] })
    end

    test 'uses the ISO week-numbering year when it differs from the calendar year' do
      weeks = Window.new(start: Date.new(2024, 12, 23), today: TODAY).weeks

      assert_equal([[52, 2024], [1, 2025]], weeks.first(2).map { [it.cweek, it.year] })
      assert_equal Date.new(2024, 12, 30), weeks.second.monday
    end

    test 'marks the current and past weeks' do
      weeks = Window.from_param(nil, today: TODAY).weeks

      assert_equal [true, false, false], weeks.first(3).map(&:past?)
      assert_equal [false, true, false], weeks.first(3).map(&:current?)
    end

    test 'has no current week when today is outside the window' do
      assert_nil Window.from_param('2027-06-07', today: TODAY).current_week_index
    end

    test 'shifts the start by whole weeks for paging' do
      window = Window.new(start: Date.new(2026, 12, 14), today: TODAY)

      assert_equal Date.new(2027, 1, 25), window.shift(6)
      assert_equal Date.new(2026, 8, 24), window.shift(-16)
      assert_equal Date.new(2026, 12, 21), window.shift(1)
    end
  end
end
