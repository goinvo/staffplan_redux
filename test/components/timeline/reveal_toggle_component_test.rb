# frozen_string_literal: true

require 'test_helper'

module Timeline
  class RevealToggleComponentTest < ViewComponent::TestCase
    test 'shows the hidden rows, keeping other query params' do
      with_request_url('/people?start=2026-10-05') { render_inline(toggle(count: 2, shown: false)) }

      assert_link 'Show 2 deactivated people', href: '/people?show_deactivated=1&start=2026-10-05'
    end

    test 'hides them again' do
      with_request_url('/people?show_deactivated=1') { render_inline(toggle(count: 1, shown: true)) }

      assert_link 'Hide 1 deactivated person', href: '/people'
    end

    test 'pluralizes the last word of the noun' do
      with_request_url('/projects?client=7') { render_inline(toggle(count: 3, shown: false, noun: 'archived project', param: 'show_archived')) }

      assert_link 'Show 3 archived projects', href: '/projects?client=7&show_archived=1'
    end

    test 'renders nothing when no rows are hidden' do
      render_inline(toggle(count: 0, shown: false))

      assert_no_selector 'tr'
    end

    private

    def toggle(noun: 'deactivated person', param: 'show_deactivated', **)
      RevealToggleComponent.new(noun:, param:, **)
    end
  end
end
