# frozen_string_literal: true

require 'test_helper'

module Timeline
  class ProjectSummaryTest < ActiveSupport::TestCase
    test 'plans estimates from the current ISO week on that have no actuals, plus every actual hour' do
      travel_to Date.new(2027, 1, 1) # Friday of ISO week 53, 2026
      company = create(:company)
      project = create(:project, client: create(:client, company:), hours: 100)
      first, second = Array.new(2) { staff(project) }
      { [first, 2026, 52] => [10, 8],
        [first, 2026, 53] => [5, 0],
        [first, 2027, 1] => [7, 0],
        [second, 2026, 53] => [4, 3],
        [second, 2027, 2] => [11, 0], }.each do |(assignment, year, cweek), (estimated_hours, actual_hours)|
        create(:work_week, assignment:, year:, cweek:, estimated_hours:, actual_hours:)
      end

      summary = ProjectSummary.for([project]).fetch(project.id)

      assert_equal [23, 11, 34, -66], [summary.future_plan, summary.actual, summary.plan, summary.delta]
      expected = [
        { label: 'Target', value: 100 },
        { label: 'Plan', value: 34, tooltip: 'Plan = Future Plan (23) + Actual (11)' },
        { label: 'Actual', value: 11 },
        { label: 'Delta', value: '-66', tooltip: 'Delta = Future Plan (23) + Actual (11) - Target (100)' },
      ]

      assert_equal expected, summary.items
    end

    test 'sums each project separately and gives projects without hours zeros' do
      company = create(:company)
      busy, idle = Array.new(2) { project_for_company(company) }
      create(:work_week, assignment: staff(busy), estimated_hours: 6, actual_hours: 2)

      summaries = ProjectSummary.for([busy, idle])

      assert_equal [0, 2], [summaries.fetch(busy.id).future_plan, summaries.fetch(busy.id).actual]
      assert_equal [0, 0], [summaries.fetch(idle.id).future_plan, summaries.fetch(idle.id).actual]
    end

    test 'leaves out target and delta without target hours' do
      [nil, 0].each do |target|
        summary = ProjectSummary.new(target:, future_plan: 5, actual: 3)

        assert_nil summary.delta
        assert_equal %w[Plan Actual], summary.items.pluck(:label)
      end
    end

    test 'signs a positive delta and delimits large numbers' do
      summary = ProjectSummary.new(target: 1000, future_plan: 1500, actual: 1200)

      assert_equal '+1,700', summary.items.last[:value]
      assert_equal 'Delta = Future Plan (1,500) + Actual (1,200) - Target (1,000)', summary.items.last[:tooltip]
      assert_equal '0', ProjectSummary.new(target: 8, future_plan: 8, actual: 0).items.last[:value]
    end

    private

    def staff(project)
      create(:assignment, project:, user: create(:membership, company: project.company).user)
    end
  end
end
