# frozen_string_literal: true

require 'test_helper'

module Timeline
  class GridComponentTest < ViewComponent::TestCase
    setup do
      travel_to Date.new(2026, 10, 8)
    end

    test 'renders a header and chart cell for every week in the window' do
      render_grid

      assert_selector 'thead th[data-timeline-week]', count: 104, visible: :all
      assert_selector 'th.navbar[data-timeline-week="1"]', visible: :all
      assert_selector 'th.bg-selectedColumnBg[data-timeline-week="1"]', visible: :all
    end

    test 'hides all but the first six weeks until the browser measures the viewport' do
      render_grid

      style = page.find('style', visible: :all).text(:all)

      assert_includes style, '#timeline [data-timeline-week="6"]'
      assert_includes style, '#timeline [data-timeline-week="51"]'
      assert_not_includes style, '[data-timeline-week="5"]'
    end

    test 'pages by six weeks, keeping other query params' do
      with_request_url '/projects?client=Acme&start=2026-10-05' do
        render_grid(start: '2026-10-05')
      end

      assert_link 'Previous weeks', href: '/projects?client=Acme&start=2026-08-24'
      assert_link 'Next weeks', href: '/projects?client=Acme&start=2026-11-16'
      assert_link 'Today', href: '/projects?client=Acme', visible: :all
    end

    test 'hides the Today link while the current week is in the window' do
      render_grid

      assert_selector 'a[hidden]', text: 'Today', visible: :hidden
      assert_selector '[data-timeline-current-week-value="1"]'

      render_grid(start: '2027-03-01')

      assert_link 'Today', visible: :visible
      assert_selector '[data-timeline-current-week-value="-1"]'
    end

    test 'renders the page header, columns, summary and rows' do
      render_inline(GridComponent.new(window: Window.from_param(nil), hours: hours_for(Window.from_param(nil)))) do |grid|
        grid.with_page_header { 'Jane Doe' }
        grid.with_columns { 'Client' }
        grid.with_summary { 'Totals' }
        '<tr><td>a row</td></tr>'.html_safe
      end

      assert_selector 'thead th', text: 'Jane Doe'
      assert_selector 'thead th', text: 'Client'
      assert_selector 'thead th', text: 'Totals'
      assert_selector 'tbody td', text: 'a row'
    end

    private

    def hours_for(window)
      WeeklyHours.new(assignments: [], window:)
    end

    def render_grid(start: nil)
      window = Window.from_param(start)
      render_inline(GridComponent.new(window:, hours: hours_for(window)))
    end
  end
end
