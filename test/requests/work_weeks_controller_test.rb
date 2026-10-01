# frozen_string_literal: true

require 'test_helper'

class WorkWeeksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @assignment = create(:assignment)
    @user = @assignment.user
    passwordless_sign_in(@user)

    @other_assignment = create(:assignment)
    @other_work_week = create(:work_week, assignment: @other_assignment, estimated_hours: 5, actual_hours: 0)
  end

  test 'creates a work week for an assignment in the current company' do
    assert_difference -> { @assignment.work_weeks.count }, 1 do
      post staffplan_work_weeks_path(@user),
           params: { work_week: { assignment_id: @assignment.id, cweek: 10, year: 2030, estimated_hours: 8 } },
           as: :turbo_stream
    end

    assert_response :success
  end

  test 'updates a work week in the current company' do
    work_week = create(:work_week, assignment: @assignment, estimated_hours: 5, actual_hours: 0)

    patch staffplan_work_week_path(@user, work_week),
          params: { work_week: { estimated_hours: 12 } },
          as: :turbo_stream

    assert_response :success
    assert_equal 12, work_week.reload.estimated_hours
  end

  test "cannot create a work week on another company's assignment" do
    assert_no_difference -> { WorkWeek.count } do
      post staffplan_work_weeks_path(@user),
           params: { work_week: { assignment_id: @other_assignment.id, cweek: 10, year: 2030, estimated_hours: 8 } },
           as: :turbo_stream
    end

    assert_response :not_found
  end

  test "cannot update another company's work week" do
    patch staffplan_work_week_path(@user, @other_work_week),
          params: { work_week: { estimated_hours: 40 } },
          as: :turbo_stream

    assert_response :not_found
    assert_equal 5, @other_work_week.reload.estimated_hours
  end

  test "cannot move a work week onto another company's assignment" do
    work_week = create(:work_week, assignment: @assignment, cweek: 1, year: 2030)

    patch staffplan_work_week_path(@user, work_week),
          params: { work_week: { assignment_id: @other_assignment.id, estimated_hours: 3 } },
          as: :turbo_stream

    assert_equal @assignment.id, work_week.reload.assignment_id
  end
end
