# frozen_string_literal: true

require 'test_helper'

module People
  class AssignmentRowComponentTest < ViewComponent::TestCase
    setup do
      travel_to Date.new(2026, 10, 8)
      @user = create(:membership).user
      @assignment = assignment_for_user(user: @user)
      @window = Timeline::Window.from_param(nil)
    end

    test 'links the client and project and toggles to proposed' do
      render_row

      assert_link @assignment.project.client.name, href: "/projects?client=#{@assignment.project.client_id}"
      assert_link @assignment.project.name, href: "/projects/#{@assignment.project_id}"
      assert_selector "form[action='/assignments/#{@assignment.id}'] input[name='assignment[status]'][value=proposed]", visible: :all
      assert_button 'Plan'
      assert_no_selector 'tr.bg-diagonal-stripes'
    end

    test 'stripes proposed assignments and toggles back to active' do
      @assignment.update!(status: Assignment::PROPOSED)
      render_row

      assert_selector 'tr.bg-diagonal-stripes'
      assert_button 'Proposed'
      assert_selector "input[name='assignment[status]'][value=active]", visible: :all
    end

    test 'totals actual hours and the plan from this week on' do
      week(-2, estimated: 10, actual: 8)
      week(0, estimated: 20, actual: 5)
      (1..8).each { week(it, estimated: 160) }

      render_row

      assert_text(/Plan\s+1,293\s*hrs/)
      assert_text(/Actual\s+13\s*hrs/)
      assert_text 'Plan = Future Plan (1,280) + Actual (13)'
    end

    test 'hides the client name on later rows of the same client when sorted by client' do
      render_row(first_client: false)

      assert_no_link @assignment.project.client.name

      render_row(first_client: false, sort: Timeline::AssignmentSort.parse('project_asc'))

      assert_link @assignment.project.client.name
    end

    test 'offers to show hidden assignments only while they are revealed' do
      @assignment.update!(focused: false)
      render_row

      assert_no_button 'Show in My StaffPlan'

      render_row(show_hidden: true)

      assert_selector "button[aria-label='Show in My StaffPlan']"
      assert_selector "input[name='assignment[focused]'][value=true]", visible: :all
    end

    test 'is read-only for deactivated people' do
      render_row(inactive: true)

      assert_no_button 'Plan'
      assert_text 'Plan'
      assert_no_selector 'input:not([disabled])', visible: :all
    end

    private

    def render_row(first_client: true, sort: Timeline::AssignmentSort.new, show_hidden: false, inactive: false)
      hours = Timeline::WeeklyHours.new(assignments: [@assignment], window: @window)
      row = AssignmentRowComponent.new(assignment: @assignment.reload, window: @window, hours:, sort:, index: 0, first_client:, show_hidden:, inactive:)
      render_inline(row)
    end

    def week(offset, estimated:, actual: 0)
      monday = Date.new(2026, 10, 5) + offset.weeks
      create(:work_week, assignment: @assignment, cweek: monday.cweek, year: monday.cwyear, estimated_hours: estimated, actual_hours: actual)
    end
  end
end
