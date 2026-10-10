# frozen_string_literal: true

require 'test_helper'

class PersonAssignmentsTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:membership).user
    @company = @user.current_company
    @client = create(:client, company: @company, name: 'Acme')
    passwordless_sign_in @user
  end

  test 'proposes an existing project for the person' do
    project = create(:project, client: @client, name: 'Website')

    propose client_name: 'acme ', project_name: 'WEBSITE'

    assert_redirected_to person_url(@user)
    assignment = @user.assignments.sole

    assert_equal [project, Assignment::PROPOSED], [assignment.project, assignment.status]
    assert_equal assignment.id, flash[:highlight]
  end

  test 'creates a new project for an existing client' do
    propose client_name: 'Acme', project_name: 'Mobile app'

    assert_equal([['Acme', 'Mobile app']], @user.assignments.map { [it.project.client.name, it.project.name] })
  end

  test 'creates a new client and project' do
    propose client_name: 'Globex ', project_name: ' Rebrand'

    assert_equal([%w[Globex Rebrand]], @user.assignments.map { [it.project.client.name, it.project.name] })
    assert_equal @company, @company.clients.find_by(name: 'Globex').company
  end

  test 'adds a project to a teammate’s staff plan' do
    teammate = create(:membership, company: @company).user

    propose user: teammate, client_name: 'Acme', project_name: 'Website'

    assert_equal(['Website'], teammate.assignments.map { it.project.name })
  end

  test 'shows validation errors inline' do
    propose client_name: '', project_name: ''

    assert_response :unprocessable_content
    assert_match 'turbo-stream action="replace" target="add_project"', response.body
    assert_match 'Client is required', response.body
    assert_match 'Project name is required', response.body
    assert_empty @user.assignments
  end

  test 'refuses a project already in the staff plan' do
    create(:assignment, user: @user, project: create(:project, client: @client, name: 'Website'))

    propose client_name: 'Acme', project_name: 'website'

    assert_response :unprocessable_content
    assert_match 'Project is already in the Staff plan', response.body
    assert_equal 1, @user.assignments.count
  end

  test 'does not reuse clients from other companies' do
    other = create(:client, name: 'Initech')

    propose client_name: 'Initech', project_name: 'TPS'

    assert_not_equal other, @user.assignments.sole.project.client
    assert_empty other.projects
  end

  test 'deactivated people and people from other companies are off limits' do
    teammate = create(:membership, company: @company)
    teammate.update!(status: Membership::INACTIVE)
    stranger = create(:membership).user

    propose user: teammate.user, client_name: 'Acme', project_name: 'Website'

    assert_response :forbidden

    propose user: stranger, client_name: 'Acme', project_name: 'Website'

    assert_response :not_found
    assert_equal 0, Assignment.count
  end

  private

  def propose(user: @user, **names)
    with_config(rails_ui_enabled: '', rails_ui_emails: @user.email) do
      post person_assignments_path(user), params: { proposed_assignment: names }, headers: { 'HTTP_REFERER' => person_url(user) }
    end
  end
end
