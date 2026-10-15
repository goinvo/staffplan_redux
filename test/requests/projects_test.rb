# frozen_string_literal: true

require 'test_helper'

class ProjectsTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:membership).user
    @company = @user.current_company
    @project = create(:project, client: create(:client, company: @company, name: 'Acme'), name: 'Website', starts_on: Date.new(2026, 10, 5))
    passwordless_sign_in @user
  end

  test 'updates only the fields sent and returns to the page' do
    update(ends_on: '2026-12-14', headers: { 'HTTP_REFERER' => project_url(@project, start: '2026-09-28') })

    assert_redirected_to project_url(@project, start: '2026-09-28')
    assert_equal ['Website', 'Acme', Date.new(2026, 10, 5), Date.new(2026, 12, 14)],
                 [@project.reload.name, @project.client.name, @project.starts_on, @project.ends_on]
  end

  test 'unarchives an archived project' do
    @project.update!(status: Project::ARCHIVED)

    update(archived: '0')

    assert_equal Project::UNCONFIRMED, @project.reload.status
  end

  test 'shows errors in the header form' do
    update(project_name: '', starts_on: '2026-12-01', ends_on: '2026-11-02')

    assert_response :unprocessable_content
    assert_match 'turbo-stream action="replace" target="project_header"', response.body
    assert_match 'Project name is required', response.body
    assert_match 'End date can&#39;t be before the start date', response.body
    assert_equal 'Website', @project.reload.name
  end

  test 'the edit dialog starts from the project and shows its errors in place' do
    get edit_project_path(@project)

    assert_dom 'turbo-frame#new_project form[action=?]', project_path(@project)
    assert_dom 'input[name="project[project_name]"][value=Website]'
    assert_dom 'input[type=checkbox][name="project[archived]"]'

    patch project_path(@project), params: { form: 'new_project', project: { project_name: '' } }

    assert_response :unprocessable_content
    assert_match 'turbo-stream action="update" target="new_project"', response.body
    assert_match 'Project name is required', response.body
  end

  test 'adds an unassigned row' do
    post project_assignments_path(@project)

    row = @project.assignments.sole

    assert_redirected_to project_path(@project)
    assert_nil row.user
    assert_equal [Assignment::PROPOSED, row.id], [row.status, flash[:highlight]]
  end

  test 'projects from other companies are not found' do
    other = create(:project, name: 'Theirs')

    patch project_path(other), params: { project: { project_name: 'Mine' } }

    assert_response :not_found

    post project_assignments_path(other)

    assert_response :not_found

    assert_equal 'Theirs', other.reload.name
    assert_empty other.assignments
  end

  private

  def update(headers: {}, **attributes)
    patch project_path(@project), params: { project: attributes }, headers:
  end
end
