# frozen_string_literal: true

require 'test_helper'

module Timeline
  class BarChartComponentTest < ViewComponent::TestCase
    test 'shows estimated hours as a teal bar scaled to the max' do
      render_chart(estimated: 1200, max: 1200, past: false)

      assert_text '1,200'
      assert_selector 'svg[height="97.56"] path[fill="#27B5B0"]'
      assert_no_selector 'path[data-proposed]'
    end

    test 'stacks proposed hours on the bottom of the bar' do
      render_chart(estimated: 40, proposed: 10, max: 50, past: false)

      assert_selector 'svg[height="50.0"]'
      assert_selector 'path[data-proposed][fill="#79e3e0"][d^="M0 50.0L0 37.5L34 37.5"]'
    end

    test 'fills the whole bar when every hour is proposed' do
      render_chart(estimated: 20, proposed: 20, max: 50, past: false)

      assert_selector 'path[data-proposed][fill="#79e3e0"][d^="M0 3C"]'
    end

    test 'shows actual hours in grey without the proposed style' do
      render_chart(actual: 30, estimated: 40, proposed: 40, max: 50, past: true)

      assert_text '30'
      assert_selector 'path[fill="#AEB3C0"]', count: 1
      assert_no_selector 'path[data-proposed]'
    end

    test 'shows 0 and no bar for a past week without actual hours' do
      render_chart(estimated: 40, max: 50, past: true)

      assert_text '0'
      assert_no_selector 'svg'
    end

    test 'draws no bar for an empty future week' do
      render_chart(max: 0, past: false)

      assert_text '0'
      assert_no_selector 'svg'
    end

    private

    def render_chart(max:, past:, actual: 0, estimated: 0, proposed: 0)
      hours = WeeklyHours::Hours.new(actual:, estimated:, proposed:)
      render_inline(BarChartComponent.new(hours:, max:, past:))
    end
  end
end
