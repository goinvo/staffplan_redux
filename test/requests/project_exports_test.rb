# frozen_string_literal: true

require 'test_helper'

class ProjectExportsTest < ActionDispatch::IntegrationTest
  setup do
    travel_to Date.new(2026, 12, 30) # Wednesday of ISO week 53, 2026
    @user = create(:membership).user
    @user.update!(name: 'Ann Lee')
    @company = @user.current_company
    passwordless_sign_in @user
  end

  test 'exports weekly hours, the summary and monthly hours per person, like React' do
    project = create(:project,
                     client: create(:client, company: @company, name: 'Acme'),
                     name: 'Website',
                     hours: 100,
                     starts_on: Date.new(2026, 12, 14),
                     ends_on: Date.new(2027, 1, 15),)
    ann = create(:assignment, project:, user: @user)
    bo = create(:assignment,
                project:,
                user: create(:membership, company: @company).user.tap { it.update!(name: 'Bo Diaz') },
                starts_on: Date.new(2027, 1, 4),
                ends_on: Date.new(2027, 1, 15),
                estimated_weekly_hours: 5,)
    placeholder = create(:assignment, :unassigned, project:)
    plan(ann, [2026, 51] => [10, 8], [2026, 53] => [12, 0], [2027, 1] => [6, 0])
    plan(bo, [2027, 2] => [9, 0])
    plan(placeholder, [2026, 52] => [4, 0])

    get project_export_path(project, format: :csv)

    assert_response :ok
    assert_equal 'text/csv', response.media_type
    assert_match 'attachment; filename="Acme-Website.csv"', response.headers['Content-Disposition']
    assert_equal <<~CSV, response.body
      Project Name;Start Date;End Date;Work Week;Plan Hours;Actual Hours;Total Hours
      Website;14.12.2026;15.01.2027;14.12.2026 - 20.12.2026;10;8;
      ;;;21.12.2026 - 27.12.2026;4;0;
      ;;;28.12.2026 - 03.01.2027;12;0;
      ;;;04.01.2027 - 10.01.2027;11;0;
      ;;;11.01.2027 - 17.01.2027;9;0;
      Target;;;;;;100
      Plan (Future Plan + Actual);;;;;;35
      Actual;;;;;;8
      Delta;;;;;;-65

      Ann Lee;December 2026;;;22;8
      Ann Lee;January 2027;;;6;0
      Bo Diaz;January 2027;;;14;0
      TBD user;December 2026;;;4;0
    CSV
  end

  test 'projects from other companies are not found' do
    get project_export_path(create(:project), format: :csv)

    assert_response :not_found
  end

  private

  def plan(assignment, weeks)
    weeks.each do |(year, cweek), (estimated_hours, actual_hours)|
      create(:work_week, assignment:, year:, cweek:, estimated_hours:, actual_hours:)
    end
  end
end
