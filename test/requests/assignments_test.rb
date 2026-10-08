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

    with_rails_ui do
      patch assignment_path(assignment), params: { assignment: { status: Assignment::PROPOSED } }, headers: { 'HTTP_REFERER' => person_url(@user, start: '2026-01-05') }
    end

    assert_response :see_other
    assert_redirected_to person_url(@user, start: '2026-01-05')
    assert_equal Assignment::PROPOSED, assignment.reload.status
  end

  test 'sending the same status twice does not flip it back' do
    assignment = assignment_for_user(user: @user)

    with_rails_ui do
      2.times { patch assignment_path(assignment), params: { assignment: { status: Assignment::PROPOSED } } }
    end

    assert_equal Assignment::PROPOSED, assignment.reload.status
  end

  test 'ignores statuses other than active and proposed' do
    assignment = assignment_for_user(user: @user)

    with_rails_ui do
      patch assignment_path(assignment), params: { assignment: { status: Assignment::ARCHIVED } }
    end

    assert_equal Assignment::ACTIVE, assignment.reload.status
  end

  test 'only the assignee can show or hide their assignment' do
    mine = assignment_for_user(user: @user)
    mine.update!(focused: false)
    teammate = create(:membership, company: @company).user
    theirs = create(:assignment, user: teammate, project: project_for_company(@company), focused: false)

    with_rails_ui do
      patch assignment_path(mine), params: { assignment: { focused: true } }
      patch assignment_path(theirs), params: { assignment: { focused: true } }
    end

    assert mine.reload.focused
    assert_not theirs.reload.focused
  end

  test "deactivated people's assignments can't be changed" do
    teammate = create(:membership, company: @company)
    assignment = create(:assignment, user: teammate.user, project: project_for_company(@company))
    teammate.update!(status: Membership::INACTIVE)

    with_rails_ui do
      patch assignment_path(assignment), params: { assignment: { status: Assignment::PROPOSED } }
    end

    assert_equal Assignment::ACTIVE, assignment.reload.status
    assert_predicate flash[:error], :present?
  end

  test 'assignments from other companies are not found' do
    other = create(:assignment)

    with_rails_ui do
      patch assignment_path(other), params: { assignment: { status: Assignment::PROPOSED } }
    end

    assert_response :not_found
    assert_equal Assignment::ACTIVE, other.reload.status
  end

  private

  def with_rails_ui(&)
    with_config(rails_ui_enabled: '', rails_ui_emails: @user.email, &)
  end
end
