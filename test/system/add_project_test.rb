# frozen_string_literal: true

require 'test_helper'

class AddProjectTest < ApplicationSystemTestCase
  ROWS = 'tbody tr[id^=assignment_]'

  setup do
    @user = create(:membership).user
    @company = @user.current_company
    @acme = create(:client, company: @company, name: 'Acme')
    passwordless_sign_in(@user)
  end

  test 'adds an existing project from an existing client' do
    create(:project, client: @acme, name: 'Website')
    create(:project, client: create(:client, company: @company, name: 'Globex'), name: 'Rebrand')

    with_rails_ui do
      open_form

      client_input.send_keys('ac')
      find('[role=option]', text: 'Acme').click

      assert_focused project_input
      assert_selector '[role=option]', text: 'Website'
      assert_no_selector '[role=option]', text: 'Rebrand'

      project_input.send_keys(:down, :enter)

      assert_equal 'Website', project_input.value
      click_button 'Save'

      assert_selector "#{ROWS}.bg-diagonal-stripes.animate-fade-in-scale", text: 'Website'
      assert_selector '#add_project', visible: :hidden
      assert evaluate_script("document.getElementById('timeline').samePage"), 'the grid was morphed in place'
      assert_equal Assignment::PROPOSED, @user.assignments.sole.status
    end
  end

  test 'adds a new project for an existing client' do
    with_rails_ui do
      open_form

      client_input.send_keys('Acme', :enter)

      assert_focused project_input

      project_input.send_keys('Mobile app')

      assert_selector '#add_project_name ~ [data-combobox-target=badge]', text: 'new'

      project_input.send_keys(:enter)

      assert_selector ROWS, text: 'Mobile app'
      assert_equal 'Acme', @user.assignments.sole.project.client.name
    end
  end

  test 'adds a new client and project' do
    with_rails_ui do
      open_form

      client_input.send_keys('Initech')

      assert_selector '#add_project_client ~ [data-combobox-target=badge]', text: 'new'

      client_input.send_keys(:tab)
      project_input.send_keys('TPS reports', :enter)

      assert_selector ROWS, text: 'TPS reports'
      assert_link 'Initech'
    end
  end

  test 'shows validation errors inline' do
    create(:assignment, user: @user, project: create(:project, client: @acme, name: 'Website'))

    with_rails_ui do
      open_form
      click_button 'Save'

      assert_text 'Client is required'
      assert_text 'Project name is required'

      client_input.send_keys('Acme', :enter)
      project_input.send_keys('website', :enter)

      assert_text 'Project is already in the Staff plan'
      assert_selector ROWS, count: 1
    end
  end

  private

  def assert_focused(input)
    assert_equal input[:id], evaluate_script('document.activeElement.id')
  end

  def client_input = find_by_id('add_project_client')

  def open_form
    visit person_path(@user)
    execute_script("document.getElementById('timeline').samePage = true")
    click_button 'Add project'

    assert_focused client_input
  end

  def project_input = find_by_id('add_project_name')

  def with_rails_ui(&)
    with_config(rails_ui_enabled: '', rails_ui_emails: @user.email, &)
  end
end
