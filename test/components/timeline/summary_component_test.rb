# frozen_string_literal: true

require 'test_helper'

module Timeline
  class SummaryComponentTest < ViewComponent::TestCase
    test 'lists each figure in hours with its tooltip' do
      items = [
        { label: 'Target', value: 1500 },
        { label: 'Plan', value: 1200, tooltip: 'Plan = Future Plan (700) + Actual (500)' },
        { label: 'Delta', value: '-300' },
      ]

      render_inline(SummaryComponent.new(items:))

      assert_selector '.border-b', text: /Target\s+1,500\s*hrs/
      assert_text(/Plan\s+1,200\s*hrs/)
      assert_selector '.border-t', text: /Delta\s+-300\s*hrs/
      assert_selector '[data-toggle-target=toggleable].hidden', text: 'Plan = Future Plan (700) + Actual (500)', visible: :all
    end

    test 'renders nothing without figures' do
      render_inline(SummaryComponent.new(items: []))

      assert_no_selector 'div'
    end
  end
end
