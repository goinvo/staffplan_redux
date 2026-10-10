# frozen_string_literal: true

require 'test_helper'

class ProjectsTest < ApplicationSystemTestCase
  ROWS = 'tbody tr[id^=project_]'

  setup do
    @user = create(:membership).user
    @company = @user.current_company
    passwordless_sign_in(@user)
  end

  test 'sorts by project or client and remembers the choice' do
    seed_projects

    with_rails_ui do
      visit projects_path

      assert_projects [%w[Globex Alpha], %w[Acme Beta], %w[Acme Zeta]]

      click_sort 'Clients', 'client_asc'

      assert_projects [%w[Acme Beta], ['', 'Zeta'], %w[Globex Alpha]]

      click_sort 'Clients', 'client_desc'

      assert_projects [%w[Globex Alpha], %w[Acme Beta], ['', 'Zeta']]

      visit projects_path

      assert_projects [%w[Globex Alpha], %w[Acme Beta], ['', 'Zeta']]

      click_sort 'Projects', 'project_asc'

      assert_projects [%w[Globex Alpha], %w[Acme Beta], %w[Acme Zeta]]

      click_link 'Beta'

      assert_current_path project_path(@beta)
    end
  end

  test 'drills into a client and back' do
    seed_projects

    with_rails_ui do
      visit projects_path
      within("tr#project_#{@beta.id}") { click_link 'Acme' }

      assert_current_path projects_path(client: @acme.id)
      assert_selector '#client_header h1', text: 'Acme'
      assert_project_names %w[Beta Zeta]
      within('#timeline thead') { assert_no_link 'Clients' }

      within('#client_header') { click_link 'Projects' }

      assert_current_path projects_path
      assert_project_names %w[Alpha Beta Zeta]
    end
  end

  test 'renames a client inline' do
    seed_projects

    with_rails_ui do
      visit projects_path(client: @acme.id)
      click_button 'Edit client'
      fill_in 'Client name', with: 'Draft'
      click_button 'Cancel'

      assert_selector '#client_header h1', text: 'Acme'

      click_button 'Edit client'

      assert_field 'Client name', with: 'Acme', focused: true

      fill_in 'Client name', with: 'globex'
      click_button 'Save'

      assert_text 'This client name is already taken. Please enter a different name.'

      find_field('Client name').send_keys(:escape)

      assert_selector '#client_header h1', text: 'Acme'
      assert_no_text 'already taken'

      click_button 'Edit client'
      fill_in 'Client name', with: 'Acme Corp'
      click_button 'Save'

      assert_selector '#client_header h1', text: 'Acme Corp'
      assert_equal 'Acme Corp', @acme.reload.name
    end
  end

  test 'shows and hides archived projects' do
    seed_projects
    [@zeta, @alpha].each { it.update!(status: Project::ARCHIVED) }

    with_rails_ui do
      visit projects_path

      assert_project_names %w[Beta]

      click_link 'Show 2 archived projects'

      assert_project_names %w[Alpha Beta Zeta]
      within("tr#project_#{@zeta.id}") { assert_text '(Archived)' }

      click_link 'Hide 2 archived projects'

      assert_project_names %w[Beta]

      visit projects_path(client: @acme.id)
      click_link 'Show 1 archived project'

      assert_project_names %w[Beta Zeta]
    end
  end

  test 'adds a project from the inline row' do
    seed_projects

    with_rails_ui do
      visit projects_path
      click_button 'Add project'

      assert_selector '#add_project_client:focus'

      find_by_id('add_project').click_button 'Save'

      assert_text 'Client is required'
      assert_text 'Project name is required'

      fill_in 'Client', with: 'Acme'
      fill_in 'Project Name', with: 'beta'
      find_field('Project Name').send_keys(:enter)

      assert_text 'Project name already in use'

      fill_in 'Client', with: 'Initech'

      assert_selector '[data-combobox-target=badge]', text: 'new'

      fill_in 'Project Name', with: 'Launch'
      find_by_id('add_project').click_button 'Save'

      assert_selector "#{ROWS}.animate-fade-in-scale", text: /Initech\s+Launch/
      launch = @company.projects.find_by!(name: 'Launch')

      assert_selector "tr#project_#{launch.id}"
      assert_no_selector '#add_project'
      assert_current_path projects_path
      assert_empty launch.assignments
    end
  end

  test 'starts with a form to create the first project' do
    with_rails_ui do
      visit projects_path

      assert_selector 'h1', text: "Let's create your first project"

      within('#first_project') do
        click_button 'Save'

        assert_text 'Project name is required'
        assert_no_button 'Cancel'

        fill_in 'Project Name', with: 'Kickoff'
        fill_in 'Client', with: 'Acme'
        click_button 'Save'
      end

      assert_selector 'h1', text: 'Kickoff'
      project = @company.projects.sole

      assert_current_path project_path(project)
      assert_equal [@user], project.users
    end
  end

  private

  def assert_project_names(names)
    assert_rows(names) { all("#{ROWS} a[href^='/projects/']").map(&:text) }
  end

  def assert_projects(rows)
    assert_rows(rows) { all(ROWS).map { |row| [row.first('td span').text, row.find("a[href^='/projects/']").text] } }
  end

  def assert_rows(expected, &)
    page.document.synchronize { raise Capybara::ExpectationNotMet unless yield == expected }

    pass
  rescue Capybara::ExpectationNotMet
    assert_equal expected, yield
  end

  def click_sort(title, sort)
    within('#timeline thead') { click_link title }

    assert_current_path projects_path(sort:)
  end

  def seed_projects
    @acme = create(:client, company: @company, name: 'Acme')
    globex = create(:client, company: @company, name: 'Globex')
    @zeta, @beta = %w[Zeta Beta].map { create(:project, client: @acme, name: it) }
    @alpha = create(:project, client: globex, name: 'Alpha')
  end

  def with_rails_ui(&)
    with_config(rails_ui_enabled: '', rails_ui_emails: @user.email, &)
  end
end
