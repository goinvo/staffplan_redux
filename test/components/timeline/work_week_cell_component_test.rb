# frozen_string_literal: true

require 'test_helper'

module Timeline
  class WorkWeekCellComponentTest < ViewComponent::TestCase
    setup do
      travel_to Date.new(2026, 10, 8)
      @assignment = assignment_for_user(user: create(:membership).user)
      @last_week, @this_week, @next_week = Window.from_param(nil).weeks.first(3)
    end

    test 'shows plan and actual inputs for past and current weeks' do
      render_cell(@this_week, estimated_hours: 20, actual_hours: 15)

      assert_selector 'td.bg-selectedColumnBg[data-timeline-week="1"]'
      assert_selector "input#estHours-#{@assignment.id}-#{@this_week.cweek}-2026[value='20'][readonly]", visible: :all
      assert_selector "input#actHours-#{@assignment.id}-#{@this_week.cweek}-2026[value='15']"
    end

    test 'has no actual input for future weeks' do
      render_cell(@next_week, estimated_hours: 20)

      assert_selector 'input', count: 1, visible: :all
      assert_selector 'input[id^=estHours]', visible: :all
    end

    test 'leaves zero hours blank unless a saved week says zero' do
      render_cell(@last_week, estimated_hours: 0, actual_hours: 0)

      assert_selector 'input:not([value])', count: 2, visible: :all

      render_cell(@last_week, estimated_hours: 0, actual_hours: 0, saved: true)

      assert_selector 'input[id^=estHours][value="0"]', visible: :all
      assert_selector 'input[id^=actHours]:not([value])'
    end

    test 'disables the inputs for deactivated people' do
      render_cell(@this_week, estimated_hours: 20, disabled: true)

      assert_selector 'input[disabled]', count: 2, visible: :all
    end

    private

    def render_cell(week, saved: false, disabled: false, **hours)
      work_week = WorkWeek.new(assignment: @assignment, cweek: week.cweek, year: week.year, **hours)
      work_week.save! if saved
      render_inline(WorkWeekCellComponent.new(assignment: @assignment, work_week:, week:, disabled:))
    end
  end
end
