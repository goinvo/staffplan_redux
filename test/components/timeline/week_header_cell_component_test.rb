# frozen_string_literal: true

require 'test_helper'

module Timeline
  class WeekHeaderCellComponentTest < ViewComponent::TestCase
    TODAY = Date.new(2026, 10, 8)

    test 'shows the Monday and its date range' do
      render_week(Date.new(2026, 10, 12))

      assert_selector 'th[data-timeline-week="0"]', text: /\A\s*12\s+12\.Oct to 18\.Oct\s*\z/
    end

    test 'labels the first week of a month with the month' do
      render_week(Date.new(2026, 11, 2))

      assert_selector 'span', exact_text: 'Nov'
    end

    test 'labels the second week of January with the year' do
      render_week(Date.new(2027, 1, 4))

      assert_selector 'span', exact_text: 'Jan'

      render_week(Date.new(2027, 1, 11))

      assert_selector 'span', exact_text: '2027'
    end

    test 'highlights the current week' do
      render_week(Date.new(2026, 10, 5))

      assert_selector 'th.bg-selectedColumnBg[aria-current=date] div.font-bold'
    end

    test 'does not highlight other weeks' do
      render_week(Date.new(2026, 10, 19))

      assert_no_selector '.bg-selectedColumnBg'
      assert_no_selector '[aria-current]'
    end

    private

    def render_week(monday)
      render_inline(WeekHeaderCellComponent.new(week: Window.new(start: monday, today: TODAY).weeks.first))
    end
  end
end
