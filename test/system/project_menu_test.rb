# frozen_string_literal: true

require 'test_helper'

class ProjectMenuTest < ApplicationSystemTestCase
  setup do
    @user = create(:membership).user
    @company = @user.current_company
    @project = create(:project, client: create(:client, company: @company, name: 'Acme'), name: 'Website', status: Project::CONFIRMED)
    passwordless_sign_in(@user)
  end

  test 'edits the project in the dialog' do
    visit projects_path
    choose_from_menu 'Edit project'

    within('dialog[open]') do
      assert_field 'Project Name', with: 'Website'

      fill_in 'Project Name', with: 'Web App'
      fill_in 'Target Hours (optional)', with: '80'
      click_button 'Save'
    end

    assert_no_selector 'dialog[open]'
    assert_link 'Web App'
    assert_equal ['Web App', 80], [@project.reload.name, @project.hours]
  end

  test 'exports the project as CSV' do
    visit projects_path
    open_menu

    assert_selector "a[download][href='#{project_export_path(@project, format: :csv)}']", text: 'Export CSV'
  end

  test 'archives from the projects page with undo, then unarchives' do
    visit projects_path
    choose_from_menu 'Archive project for everyone'

    assert_text 'Project archived for everyone'
    assert_text "Archiving removes the project from everyone's view, including its hours."

    click_button 'Undo'

    assert_link 'Website'

    shorten_undo_window
    choose_from_menu 'Archive project for everyone'

    assert_link 'Show 1 archived project'
    assert_no_link 'Website'
    assert_predicate @project.reload, :archived?

    click_link 'Show 1 archived project'
    choose_from_menu 'Unarchive project for everyone'

    assert_no_button '(Archived)'
    assert_equal Project::UNCONFIRMED, @project.reload.status
  end

  test 'the (Archived) label unarchives' do
    @project.update!(status: Project::ARCHIVED)

    visit projects_path(show_archived: 1)
    click_button '(Archived)'

    assert_no_button '(Archived)'
    assert_link 'Website'

    assert_equal Project::UNCONFIRMED, @project.reload.status
  end

  test 'hides, shows and removes your assignment from the projects page right away' do
    assignment = create(:assignment, project: @project, user: @user)

    visit projects_path
    choose_from_menu 'Hide in My StaffPlan'

    assert_selector "button[aria-label='Show in My StaffPlan']"

    choose_from_menu 'Show in My StaffPlan'

    assert_no_selector "button[aria-label='Show in My StaffPlan']"

    choose_from_menu 'Delete me from this project'
    open_menu

    assert_no_button 'Delete me from this project'
    assert_no_button 'Hide in My StaffPlan'

    assert_not Assignment.exists?(assignment.id)
  end

  test 'hides from My StaffPlan with undo' do
    assignment = create(:assignment, project: @project, user: @user)

    visit person_path(@user)
    choose_from_menu 'Hide in My StaffPlan'

    assert_text 'Project hidden from My StaffPlan'

    click_button 'Undo'

    assert_link 'Website'

    shorten_undo_window
    choose_from_menu 'Hide in My StaffPlan'

    assert_no_link 'Website'
    assert_no_text 'Project hidden from My StaffPlan'
    assert_not assignment.reload.focused
  end

  test 'deletes yourself from a project in My StaffPlan with undo' do
    assignment = create(:assignment, project: @project, user: @user)
    @user.update!(name: 'Ann Lee')

    visit person_path(@user)
    shorten_undo_window(1000)
    choose_from_menu 'Delete me from this project'

    assert_text 'Deleted Ann and their proposed/plan hours from this project'
    assert_no_text 'Deleted Ann', wait: 5
    assert_no_link 'Website'
    assert_not Assignment.exists?(assignment.id)
  end

  test 'archives from My StaffPlan with undo' do
    create(:assignment, project: @project, user: @user)

    visit person_path(@user)
    shorten_undo_window
    choose_from_menu 'Archive project for everyone'

    assert_no_link 'Website'
    assert_no_text 'Project archived for everyone'
    assert_predicate @project.reload, :archived?
  end

  private

  def choose_from_menu(item)
    open_menu
    find('[role=menu]', visible: :visible).click_button(item)
  end

  def open_menu
    click_button "Menu for #{@project.reload.name}"
  end

  def shorten_undo_window(delay = 300)
    execute_script("document.querySelectorAll('[data-controller~=undo]').forEach((row) => row.dataset.undoDelayValue = #{delay})")
  end
end
