# frozen_string_literal: true

require 'test_helper'

class NewProjectTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:membership).user
    @company = @user.current_company
    passwordless_sign_in @user
  end

  test 'the form lists the company’s clients' do
    create(:client, company: @company, name: 'Acme')
    create(:client, name: 'Elsewhere')

    with_rails_ui { get new_project_path }

    assert_response :ok
    assert_dom 'turbo-frame#new_project [role=option]', text: 'Acme'
    assert_dom '[role=option]', text: 'Elsewhere', count: 0
  end

  test 'creates the project with a new client and proposes the creator' do
    create_project project_name: ' Rebrand ', client_name: 'Globex', hours: '1,200', starts_on: '2026-11-02', ends_on: '2027-03-01'

    project = @company.projects.sole

    assert_redirected_to project_path(project)
    assert_equal ['Rebrand', 'Globex', 1200, Date.new(2026, 11, 2), Date.new(2027, 3, 1)], [project.name, project.client.name, project.hours, project.starts_on, project.ends_on]
    assert_equal([[@user, Assignment::PROPOSED]], project.assignments.map { [it.user, it.status] })
  end

  test 'uses an existing client case-insensitively' do
    client = create(:client, company: @company, name: 'Acme')

    create_project project_name: 'Website', client_name: 'acme'

    assert_equal client, @company.projects.sole.client
  end

  test 'shows validation errors in the modal' do
    create(:project, client: create(:client, company: @company, name: 'Acme'), name: 'Website')

    create_project project_name: '', client_name: ''

    assert_response :unprocessable_content
    assert_match 'turbo-stream action="update" target="new_project"', response.body
    assert_match 'Client is required', response.body
    assert_match 'Project name is required', response.body

    create_project project_name: 'website', client_name: 'Acme', hours: 'lots', starts_on: '2026-11-02', ends_on: '2026-10-01'

    assert_match 'Project name already in use', response.body
    assert_match 'Target hours must be a whole number', response.body
    assert_match 'End date can&#39;t be before the start date', response.body
    assert_equal 1, @company.projects.count
  end

  private

  def create_project(**attributes)
    with_rails_ui { post projects_path, params: { new_project: attributes } }
  end

  def with_rails_ui(&)
    with_config(rails_ui_enabled: '', rails_ui_emails: @user.email, &)
  end
end
