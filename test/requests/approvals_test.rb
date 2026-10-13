# frozen_string_literal: true

require 'test_helper'

class ApprovalsTest < ActionDispatch::IntegrationTest
  setup do
    travel_to Date.new(2026, 10, 8)
    @user = create(:membership).user
    @company = @user.current_company
    @assignment = assignment_for_user(user: @user)
    create(:work_week, assignment: @assignment, cweek: 41, year: 2026, estimated_hours: 30, actual_hours: 0)
    passwordless_sign_in @user
  end

  test 'records your planned hours for the week and returns to the page' do
    approve(@user, week: '2026-10-05', headers: { 'HTTP_REFERER' => person_url(@user, start: '2026-09-28') })

    assert_redirected_to person_url(@user, start: '2026-09-28')
    assert_equal 30, @assignment.work_weeks.sole.actual_hours
  end

  test 'skips hidden assignments and archived projects' do
    hidden = assignment_for_user(user: @user)
    hidden.update!(focused: false)
    archived = assignment_for_user(user: @user)
    archived.project.update!(status: Project::ARCHIVED)
    [hidden, archived].each { create(:work_week, assignment: it, cweek: 41, year: 2026, estimated_hours: 8, actual_hours: 0) }

    approve(@user, week: '2026-10-05')

    assert_equal([0, 0], [hidden, archived].map { it.work_weeks.sole.actual_hours })
  end

  test 'future weeks are refused' do
    approve(@user, week: '2026-10-12')

    assert_equal 'Hours can only be recorded for past weeks without actual hours', flash[:error]
  end

  test "you can't approve someone else's hours" do
    teammate = create(:membership, company: @company).user

    approve(teammate, week: '2026-10-05')

    assert_response :forbidden
  end

  test 'a bad week is a bad request' do
    approve(@user, week: 'someday')

    assert_response :bad_request
  end

  private

  def approve(user, week:, headers: {})
    with_config(rails_ui_enabled: '', rails_ui_emails: @user.email) { post person_approval_path(user), params: { week: }, headers: }
  end
end
