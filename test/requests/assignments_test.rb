# frozen_string_literal: true

require 'test_helper'

class AssignmentsTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:membership).user
    @company = @user.current_company
    passwordless_sign_in @user
  end

  test 'toggles between active and proposed and returns to the page' do
    assignment = assignment_for_user(user: @user)

    patch assignment_path(assignment), params: { assignment: { status: Assignment::PROPOSED } }, headers: { 'HTTP_REFERER' => person_url(@user, start: '2026-01-05') }

    assert_response :see_other
    assert_redirected_to person_url(@user, start: '2026-01-05')
    assert_equal Assignment::PROPOSED, assignment.reload.status
  end

  test 'sending the same status twice does not flip it back' do
    assignment = assignment_for_user(user: @user)

    2.times { patch assignment_path(assignment), params: { assignment: { status: Assignment::PROPOSED } } }

    assert_equal Assignment::PROPOSED, assignment.reload.status
  end

  test 'ignores statuses other than active and proposed' do
    assignment = assignment_for_user(user: @user)

    patch assignment_path(assignment), params: { assignment: { status: Assignment::ARCHIVED } }

    assert_equal Assignment::ACTIVE, assignment.reload.status
  end

  test 'only the assignee can show or hide their assignment' do
    mine = assignment_for_user(user: @user)
    mine.update!(focused: false)
    teammate = create(:membership, company: @company).user
    theirs = create(:assignment, user: teammate, project: project_for_company(@company), focused: false)

    patch assignment_path(mine), params: { assignment: { focused: true } }
    patch assignment_path(theirs), params: { assignment: { focused: true } }

    assert mine.reload.focused
    assert_not theirs.reload.focused
  end

  test "deactivated people's assignments can't be changed" do
    teammate = create(:membership, company: @company)
    assignment = create(:assignment, user: teammate.user, project: project_for_company(@company))
    teammate.update!(status: Membership::INACTIVE)

    patch assignment_path(assignment), params: { assignment: { status: Assignment::PROPOSED } }

    assert_equal Assignment::ACTIVE, assignment.reload.status
    assert_predicate flash[:error], :present?
  end

  test 'assignments from other companies are not found' do
    other = create(:assignment)

    patch assignment_path(other), params: { assignment: { status: Assignment::PROPOSED } }

    assert_response :not_found
    assert_equal Assignment::ACTIVE, other.reload.status
  end

  test 'assigns an active teammate to an unassigned row, once' do
    project = project_for_company(@company)
    row = create(:assignment, :unassigned, project:)
    teammate = create(:membership, company: @company).user
    departed = create(:membership, company: @company, status: Membership::INACTIVE).user

    patch assignment_path(row), params: { assignment: { user_id: departed.id } }

    assert_nil row.reload.user

    patch assignment_path(row), params: { assignment: { user_id: teammate.id } }, headers: { 'HTTP_REFERER' => project_url(project) }

    assert_redirected_to project_url(project)
    assert_equal teammate, row.reload.user
    assert_equal row.id, flash[:highlight]

    patch assignment_path(row), params: { assignment: { user_id: @user.id } }

    assert_equal teammate, row.reload.user
  end

  test 'deletes unassigned rows and your own assignments without actual hours' do
    project = project_for_company(@company)
    row = create(:assignment, :unassigned, project:)
    mine = create(:assignment, user: @user, project:)

    delete assignment_path(row), headers: { 'HTTP_REFERER' => project_url(project) }

    assert_redirected_to project_url(project)

    delete assignment_path(mine)

    assert_redirected_to project_path(project)

    assert_empty project.assignments.reload
  end

  test "members can't delete teammates' assignments, and nobody can delete actual hours" do
    @company.memberships.find_by(user: @user).update!(role: Membership::MEMBER)
    project = project_for_company(@company)
    theirs = create(:assignment, user: create(:membership, company: @company).user, project:)
    mine = create(:assignment, user: @user, project:)
    create(:work_week, assignment: mine, estimated_hours: 8, actual_hours: 6)

    delete assignment_path(theirs)

    assert_response :forbidden

    delete assignment_path(mine)

    assert_response :forbidden

    assert_equal 2, project.assignments.count
  end

  test "owners and admins can delete teammates' assignments" do
    project = project_for_company(@company)
    theirs = create(:assignment, user: create(:membership, company: @company).user, project:)

    delete assignment_path(theirs)

    assert_response :see_other
    assert_empty project.assignments
  end
end
