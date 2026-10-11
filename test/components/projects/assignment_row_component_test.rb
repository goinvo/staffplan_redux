# frozen_string_literal: true

require 'test_helper'

module Projects
  class AssignmentRowComponentTest < ViewComponent::TestCase
    setup do
      travel_to Date.new(2026, 10, 8)
      @viewer = create(:membership).user
      @company = @viewer.current_company
      @project = project_for_company(@company)
      @teammate = create(:membership, company: @company).user.tap { it.update!(name: 'Bo Diaz') }
    end

    test 'an unassigned row offers available people and can be deleted' do
      row = create(:assignment, :unassigned, project: @project)

      render_row(row, available_users: [@teammate])

      assert_select 'Add person', with_options: ['Bo Diaz']
      assert_button 'Delete person from project', visible: :all
      assert_no_button 'Proposed'
      assert_selector 'input[aria-label^="Unassigned actual hours"][disabled]', visible: :all
    end

    test "a teammate's row links to them, toggles status, and only managers may delete it" do
      assignment = create(:assignment, project: @project, user: @teammate)

      render_row(assignment, manager: false)

      assert_link 'Bo Diaz', href: "/people/#{@teammate.id}"
      assert_button 'Plan'
      assert_no_button 'Menu for Bo Diaz'

      render_row(assignment, manager: true)

      assert_button 'Delete Bo from project', visible: :all
    end

    test 'rows with actual hours cannot be deleted' do
      assignment = create(:assignment, project: @project, user: @viewer)
      create(:work_week, assignment:, estimated_hours: 8, actual_hours: 4)

      render_row(assignment, manager: true)

      assert_no_button "Menu for #{@viewer.name}"
    end

    test 'your hidden assignment offers to show it again' do
      assignment = create(:assignment, project: @project, user: @viewer, focused: false)

      render_row(assignment)

      assert_button 'Show in My StaffPlan'
      assert_text 'Hidden in My StaffPlan'
    end

    test 'deactivated people are read-only' do
      assignment = create(:assignment, project: @project, user: @teammate)

      render_row(assignment, inactive: true)

      assert_text '(Deactivated)'
      assert_no_button 'Plan'
      assert_selector 'input[aria-label^="Bo Diaz plan hours"][disabled]', visible: :all
    end

    private

    def render_row(assignment, manager: false, inactive: false, available_users: [])
      hours = Timeline::WeeklyHours.new(assignments: [assignment], window: Timeline::Window.from_param(nil))
      render_inline(AssignmentRowComponent.new(assignment:, hours:, viewer: @viewer, manager:, available_users:, inactive:))
    end
  end
end
