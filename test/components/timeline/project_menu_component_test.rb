# frozen_string_literal: true

require 'test_helper'

module Timeline
  class ProjectMenuComponentTest < ViewComponent::TestCase
    setup do
      @viewer = create(:membership).user
      @company = @viewer.current_company
      @project = project_for_company(@company)
    end

    test 'everyone can edit, export and archive' do
      render_menu(assignment: nil)

      assert_button 'Edit project', visible: :all
      assert_selector "button[data-shortcuts-url-param='/projects/#{@project.id}/edit']", visible: :all
      assert_link 'Export CSV', href: "/projects/#{@project.id}/export.csv", visible: :all
      assert_selector "button[data-undo-url-param='/projects/#{@project.id}'][data-undo-template-param=archived]", text: 'Archive project for everyone', visible: :all
      assert_selector 'template[data-name=archived]', visible: :all
      assert_no_button 'Hide in My StaffPlan', visible: :all
      assert_no_button 'Delete me from this project', visible: :all
    end

    test 'archived projects offer to unarchive right away' do
      @project.update!(status: Project::ARCHIVED)

      render_menu(assignment: nil)

      assert_button 'Unarchive project for everyone', visible: :all
      assert_no_button 'Archive project for everyone', visible: :all
    end

    test 'on an assignment row, hiding and deleting your assignment wait for the undo window' do
      mine = create(:assignment, project: @project, user: @viewer)

      render_menu(assignment: mine, assignment_row: true)

      assert_selector 'button[data-undo-template-param=hidden][data-undo-method-param=patch]', text: 'Hide in My StaffPlan', visible: :all
      assert_selector 'button[data-undo-template-param=deleted][data-undo-method-param=delete]', text: 'Delete me from this project', visible: :all
      assert_selector 'template[data-name=deleted]', visible: :all
    end

    test 'on a project row, they happen right away' do
      mine = create(:assignment, project: @project, user: @viewer, focused: false)

      render_menu(assignment: mine)

      assert_selector "form[action='/assignments/#{mine.id}'] button", text: 'Show in My StaffPlan', visible: :all
      assert_selector "form[action='/assignments/#{mine.id}'] input[name=_method][value=delete]", visible: :all
      assert_no_selector 'template[data-name=deleted]', visible: :all
    end

    test "only managers can delete a teammate's assignment, and never one with actual hours" do
      theirs = create(:assignment, project: @project, user: create(:membership, company: @company).user.tap { it.update!(name: 'Bo Diaz') })

      render_menu(assignment: theirs, assignment_row: true)

      assert_no_button 'Delete Bo from this project', visible: :all
      assert_no_button 'Hide in My StaffPlan', visible: :all

      render_menu(assignment: theirs, assignment_row: true, manager: true)

      assert_button 'Delete Bo from this project', visible: :all

      create(:work_week, assignment: theirs, estimated_hours: 8, actual_hours: 3)
      render_menu(assignment: theirs.reload, assignment_row: true, manager: true)

      assert_no_button 'Delete Bo from this project', visible: :all
    end

    private

    def render_menu(assignment:, assignment_row: false, manager: false)
      render_inline(ProjectMenuComponent.new(project: @project, assignment:, viewer: @viewer, manager:, assignment_row:))
    end
  end
end
