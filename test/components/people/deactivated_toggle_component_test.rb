# frozen_string_literal: true

require 'test_helper'

module People
  class DeactivatedToggleComponentTest < ViewComponent::TestCase
    test 'shows deactivated people, keeping other query params' do
      with_request_url('/people?start=2026-10-05') { render_inline(DeactivatedToggleComponent.new(count: 2, shown: false)) }

      assert_link 'Show 2 deactivated people', href: '/people?show_deactivated=1&start=2026-10-05'
    end

    test 'hides them again' do
      with_request_url('/people?show_deactivated=1') { render_inline(DeactivatedToggleComponent.new(count: 1, shown: true)) }

      assert_link 'Hide 1 deactivated person', href: '/people'
    end

    test 'renders nothing without deactivated people' do
      render_inline(DeactivatedToggleComponent.new(count: 0, shown: false))

      assert_no_selector 'tr'
    end
  end
end
