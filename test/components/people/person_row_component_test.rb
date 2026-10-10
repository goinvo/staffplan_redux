# frozen_string_literal: true

require 'test_helper'

module People
  class PersonRowComponentTest < ViewComponent::TestCase
    setup do
      travel_to Date.new(2026, 10, 8)
      @user = create(:membership).user
      @window = Timeline::Window.from_param(nil)
    end

    test 'links to the person and charts their weekly totals' do
      assignment = assignment_for_user(user: @user)
      next_week = @window.weeks.third
      create(:work_week, assignment:, cweek: next_week.cweek, year: next_week.year, estimated_hours: 32, actual_hours: 0)

      render_row(assignments: [assignment])

      assert_link @user.name, href: "/people/#{@user.id}"
      assert_selector 'td[data-timeline-week]', count: Timeline::Window::WEEK_COUNT, visible: :all
      assert_selector 'td.bg-selectedColumnBg[data-timeline-week="1"]', visible: :all
      assert_selector 'td[data-timeline-week="2"] svg', visible: :all
      assert_selector 'td[data-timeline-week="2"] span.text-contrastBlue', text: '32', visible: :all
      assert_no_text '(Deactivated)'
    end

    test 'marks deactivated people' do
      render_row(deactivated: true)

      assert_link "#{@user.name} (Deactivated)"
    end

    private

    def render_row(assignments: [], deactivated: false)
      hours = Timeline::WeeklyHours.new(assignments:, window: @window)
      render_inline(PersonRowComponent.new(user: @user, hours:, deactivated:))
    end
  end
end
