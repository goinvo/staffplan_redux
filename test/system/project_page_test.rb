# frozen_string_literal: true

require 'test_helper'

class ProjectPageTest < ApplicationSystemTestCase
  ROWS = 'tbody tr[id^=assignment_]'

  setup do
    @user = create(:membership).user
    @user.update!(name: 'Ann Lee')
    @company = @user.current_company
    @acme = create(:client, company: @company, name: 'Acme')
    @project = create(:project, client: @acme, name: 'Website', status: Project::CONFIRMED)
    passwordless_sign_in(@user)
  end

  test 'edits the project in the header' do
    with_rails_ui do
      visit project_path(@project)
      click_button 'Edit project'

      assert_field 'Project name', with: 'Website', focused: true

      fill_in 'Project name', with: ''
      click_button 'Save'

      assert_text 'Project name is required'

      find_field('Project name').send_keys(:escape)

      assert_selector 'h1', text: 'Website'
      assert_no_text 'Project name is required'

      click_button 'Edit project'
      fill_in 'Project name', with: 'Web App'
      fill_in 'Client', with: 'Globex'
      fill_in 'Hours', with: '1,200'
      fill_in 'Starts', with: Date.new(2026, 10, 1)
      fill_in 'Ends', with: Date.new(2026, 12, 15)
      click_button 'Save'

      assert_selector 'h1', text: 'Web App'
      assert_text 'Globex, 1.Oct — 15.Dec.2026'
      within('#timeline thead') { assert_text 'Target' }
      assert_equal ['Web App', 'Globex', 1200], [@project.reload.name, @project.client.name, @project.hours]
    end
  end

  test 'archives with the checkbox and unarchives with the (Archived) link' do
    with_rails_ui do
      visit project_path(@project)
      click_button 'Edit project'
      check 'Archive project for everyone?'
      click_button 'Save'

      assert_button '(Archived)'
      assert_equal Project::ARCHIVED, @project.reload.status

      click_button '(Archived)'

      assert_no_button '(Archived)'
      assert_equal Project::UNCONFIRMED, @project.reload.status
    end
  end

  test 'drags the start and end markers to other weeks' do
    travel_to Date.new(2026, 10, 8)
    @project.update!(starts_on: Date.new(2026, 10, 7), ends_on: Date.new(2026, 11, 4))

    with_rails_ui do
      visit project_path(@project)
      marker('starts_on').drag_to(week('2026-10-19'))

      assert_text 'Acme, 19.Oct — 4.Nov.2026'

      marker('ends_on').drag_to(week('2026-10-12'))
      marker('ends_on').drag_to(week('2026-10-26'))

      assert_text 'Acme, 19.Oct — 26.Oct.2026'
    end

    assert_equal [Date.new(2026, 10, 19), Date.new(2026, 10, 26)], [@project.reload.starts_on, @project.ends_on]
  end

  test 'adds an unassigned row and assigns a person to it' do
    create(:membership, company: @company).user.update!(name: 'Bo Diaz')
    create(:assignment, project: @project, user: @user)

    with_rails_ui do
      visit project_path(@project)
      click_button 'Add person'

      assert_selector "#{ROWS}.animate-fade-in-scale", text: 'Proposed'
      assert_select 'Add person', with_options: ['Bo Diaz']

      select 'Bo Diaz', from: 'Add person'

      assert_selector "#{ROWS}.animate-fade-in-scale", text: 'Bo Diaz'
      assert_no_select 'Add person'
    end

    assert_equal ['Ann Lee', 'Bo Diaz'], @project.users.order(:name).map(&:name)
  end

  test 'deletes a placeholder row after the undo window, and undo keeps it' do
    row = create(:assignment, :unassigned, project: @project)

    with_rails_ui do
      visit project_path(@project)
      delete_placeholder

      assert_text 'Deleted person and their proposed/plan hours from this project'

      click_button 'Undo'

      assert_select 'Add person'

      shorten_undo_window
      delete_placeholder

      assert_no_text 'Deleted person'
      assert_no_selector ROWS
    end

    assert_not Assignment.exists?(row.id)
  end

  test 'leaving the page during the undo window still deletes the row' do
    row = create(:assignment, :unassigned, project: @project)

    with_rails_ui do
      visit project_path(@project)
      delete_placeholder
      within('nav[aria-label=Main]') { click_link 'People' }

      assert_current_path people_path
      assert(wait_until { !Assignment.exists?(row.id) })
    end
  end

  test 'sorts people and remembers the choice' do
    %w[Cy Bo].each do |name|
      create(:assignment, project: @project, user: create(:membership, company: @company).user.tap { it.update!(name:) })
    end
    create(:assignment, project: @project, user: @user)

    with_rails_ui do
      visit project_path(@project)

      assert_people ['Ann Lee', 'Bo', 'Cy']

      within('#timeline thead') { click_link 'People' }

      assert_people ['Cy', 'Bo', 'Ann Lee']

      visit project_path(@project)

      assert_people ['Cy', 'Bo', 'Ann Lee']
    end
  end

  private

  def assert_people(names)
    assert_rows(names) { all("#{ROWS} a[href^='/people/']").map(&:text) }
  end

  def delete_placeholder
    click_button 'Menu for unassigned person'
    click_button 'Delete person from project'
  end

  def marker(kind)
    find("#timeline thead th[data-marker=#{kind}]")
  end

  def shorten_undo_window
    execute_script("document.querySelectorAll('[data-controller~=undo]').forEach((row) => row.dataset.undoDelayValue = 200)")
  end

  def wait_until
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep 0.05 until (result = yield)
      result
    end
  end

  def week(monday)
    find("#timeline thead th[data-date='#{monday}']")
  end

  def with_rails_ui(&)
    with_config(rails_ui_enabled: '', rails_ui_emails: @user.email, &)
  end
end
