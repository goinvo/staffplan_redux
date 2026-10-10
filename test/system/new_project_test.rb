# frozen_string_literal: true

require 'test_helper'

class NewProjectTest < ApplicationSystemTestCase
  setup do
    @user = create(:membership).user
    @company = @user.current_company
    passwordless_sign_in(@user)
  end

  test 'creates a project with a new client from the + button' do
    with_rails_ui do
      visit person_path(@user)
      click_button 'New project'

      within_dialog do
        fill_in 'Project Name', with: 'Rebrand'
        fill_in 'Client', with: 'Globex'

        assert_selector '[data-combobox-target=badge]', text: 'new'

        fill_in 'Target Hours (optional)', with: '120'
        click_button 'Save'
      end

      assert_selector 'h1', text: 'Rebrand'
      project = @company.projects.find_by!(name: 'Rebrand')

      assert_current_path project_path(project)
      assert_no_selector 'dialog[open]'
      assert_equal ['Globex', 120], [project.client.name, project.hours]
    end
  end

  test 'creates a project for an existing client with the n shortcut' do
    create(:client, company: @company, name: 'Acme')

    with_rails_ui do
      visit person_path(@user)
      find('body').send_keys('n')

      within_dialog do
        assert_selector '#new_project_project_name:focus'

        fill_in 'Project Name', with: 'Website'
        find_field('Client').send_keys('ac', :down, :enter)

        assert_field 'Client', with: 'Acme'
        click_button 'Save'
      end

      assert_selector 'h1', text: 'Website'
      assert_equal 'Acme', @company.projects.sole.client.name
    end
  end

  test 'shows validation errors inside the modal' do
    with_rails_ui do
      visit person_path(@user)
      click_button 'New project'

      within_dialog do
        click_button 'Save'

        assert_text 'Project name is required'
        assert_text 'Client is required'
      end

      assert_current_path person_path(@user)
    end
  end

  test 'cancel and escape close the modal' do
    with_rails_ui do
      visit person_path(@user)
      click_button 'New project'
      within_dialog { click_button 'Cancel' }

      assert_no_selector 'dialog[open]'

      click_button 'New project'
      within_dialog { fill_in 'Project Name', with: 'Draft' }
      find_field('Project Name').send_keys(:escape)

      assert_no_selector 'dialog[open]'

      click_button 'New project'

      within_dialog { assert_field 'Project Name', with: '' }
      assert_empty @company.projects
    end
  end

  private

  def with_rails_ui(&)
    with_config(rails_ui_enabled: '', rails_ui_emails: @user.email, &)
  end

  def within_dialog(&)
    within('dialog[open]', &)
  end
end
