# frozen_string_literal: true

require 'test_helper'

class AssignmentWorkWeeksTest < ActionDispatch::IntegrationTest
  setup do
    travel_to Date.new(2026, 10, 8)
    @user = create(:membership).user
    @company = @user.current_company
    @assignment = assignment_for_user(user: @user)
    passwordless_sign_in @user
  end

  test 'saves plan and actual hours for a week' do
    save_week(cweek: 40, estimated_hours: '20', actual_hours: '15')

    assert_response :no_content
    assert_hours [40, 20, 15]
  end

  test 'updates an existing week' do
    create(:work_week, assignment: @assignment, cweek: 40, year: 2026, estimated_hours: 10, actual_hours: 5)

    save_week(cweek: 40, estimated_hours: '12', actual_hours: '8')

    assert_hours [40, 12, 8]
  end

  test 'any member of the company can edit a teammate’s hours' do
    teammate = create(:membership, company: @company).user
    assignment = create(:assignment, user: teammate, project: project_for_company(@company))

    save_week(assignment:, cweek: 42, estimated_hours: '6')

    assert_response :no_content
    assert_equal 6, assignment.work_weeks.sole.estimated_hours
  end

  test 'blanking a future week deletes it' do
    create(:work_week, assignment: @assignment, cweek: 43, year: 2026, estimated_hours: 10, actual_hours: 0)

    save_week(cweek: 43, estimated_hours: '')

    assert_response :no_content
    assert_hours
  end

  test 'blanking a past week keeps it at zero' do
    create(:work_week, assignment: @assignment, cweek: 39, year: 2026, estimated_hours: 10, actual_hours: 4)

    save_week(cweek: 39, estimated_hours: '', actual_hours: '4')

    assert_hours [39, 0, 4]
  end

  test 'future weeks never record actual hours' do
    save_week(cweek: 43, estimated_hours: '10', actual_hours: '9')

    assert_hours [43, 10, 0]
  end

  test 'saving the plan alone keeps the actual hours' do
    create(:work_week, assignment: @assignment, cweek: 40, year: 2026, estimated_hours: 10, actual_hours: 4)

    save_week(cweek: 40, estimated_hours: '12')

    assert_hours [40, 12, 4]
  end

  test 'rejects more than 168 hours with a message' do
    save_week(cweek: 40, estimated_hours: '169')

    assert_response :unprocessable_content
    assert_match(/less than or equal to 168/, flash[:error])
    assert_hours
  end

  test 'deactivated people’s weeks after they left are locked' do
    teammate = create(:membership, company: @company)
    assignment = create(:assignment, user: teammate.user, project: project_for_company(@company))
    travel_to(Date.new(2026, 9, 2)) { teammate.update!(status: Membership::INACTIVE) }

    save_week(assignment:, cweek: 36, estimated_hours: '5')
    save_week(assignment:, cweek: 37, estimated_hours: '5')

    assert_response :unprocessable_content
    assert_equal 'Unable to edit future work weeks for inactive users', flash[:error]
    assert_equal [36], assignment.work_weeks.pluck(:cweek)
  end

  test 'assignments from other companies are not found' do
    other = create(:assignment)

    save_week(assignment: other, cweek: 40, estimated_hours: '10')

    assert_response :not_found
    assert_empty other.work_weeks.reload
  end

  test 'fill forward copies the plan through the last visible week' do
    create(:work_week, assignment: @assignment, cweek: 41, year: 2026, estimated_hours: 1, actual_hours: 3)

    fill_forward(cweek: 40, estimated_hours: '8', through: '2026-10-19')

    assert_response :no_content
    assert_hours [40, 8, 0], [41, 8, 3], [42, 8, 0], [43, 8, 0]
  end

  test 'fill forward stops at the assignment end date and crosses years' do
    @assignment.update!(starts_on: Date.new(2026, 1, 1), ends_on: Date.new(2027, 1, 6))

    fill_forward(cweek: 52, estimated_hours: '4', through: '2027-02-01')

    assert_equal [[52, 2026], [53, 2026], [1, 2027]], @assignment.work_weeks.order(:year, :cweek).pluck(:cweek, :year)
  end

  test 'fill forward with a blank plan does nothing' do
    fill_forward(cweek: 42, estimated_hours: '', through: '2026-11-02')

    assert_response :no_content
    assert_hours
  end

  test 'fill forward reports locked weeks for deactivated people' do
    teammate = create(:membership, company: @company)
    assignment = create(:assignment, user: teammate.user, project: project_for_company(@company))
    teammate.update!(status: Membership::INACTIVE)

    fill_forward(assignment:, cweek: 41, estimated_hours: '5', through: '2026-10-19')

    assert_response :unprocessable_content
    assert_equal 'Unable to update 2 future work week(s) for an inactive user', flash[:error]
    assert_equal [41], assignment.work_weeks.pluck(:cweek)
  end

  test 'fill forward rejects bad weeks and dates' do
    fill_forward(cweek: 60, estimated_hours: '5', through: '2026-10-19')

    assert_response :bad_request

    fill_forward(cweek: 42, estimated_hours: '5', through: 'soon')

    assert_response :bad_request
  end

  private

  def assert_hours(*weeks)
    assert_equal weeks, @assignment.work_weeks.order(:year, :cweek).pluck(:cweek, :estimated_hours, :actual_hours)
  end

  def fill_forward(cweek:, through:, assignment: @assignment, **hours)
    with_rails_ui do
      post fill_forward_assignment_work_week_path(assignment), params: { work_week: { cweek:, year: 2026, **hours }, through: }
    end
  end

  def save_week(cweek:, assignment: @assignment, **hours)
    with_rails_ui do
      patch assignment_work_week_path(assignment), params: { work_week: { cweek:, year: 2026, **hours } }
    end
  end

  def with_rails_ui(&)
    with_config(rails_ui_enabled: '', rails_ui_emails: @user.email, &)
  end
end
