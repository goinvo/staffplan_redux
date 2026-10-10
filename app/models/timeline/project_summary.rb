# frozen_string_literal: true

module Timeline
  class ProjectSummary
    attr_reader :target, :future_plan, :actual

    def self.for(projects, today: Time.zone.today)
      work_weeks = WorkWeek.joins(:assignment).where(assignments: { project_id: projects.map(&:id) }).group('assignments.project_id')
      actuals = work_weeks.sum(:actual_hours)
      future_plans = work_weeks.from_week_of(today).where(actual_hours: 0).sum(:estimated_hours)

      projects.to_h { [it.id, new(target: it.hours, future_plan: future_plans.fetch(it.id, 0), actual: actuals.fetch(it.id, 0))] }
    end

    def initialize(target:, future_plan:, actual:)
      @target = target.to_i
      @future_plan = future_plan
      @actual = actual
    end

    def delta
      plan - target if target?
    end

    def items
      [
        ({ label: 'Target', value: target } if target?),
        { label: 'Plan', value: plan, tooltip: "Plan = Future Plan (#{number(future_plan)}) + Actual (#{number(actual)})" },
        { label: 'Actual', value: actual },
        ({ label: 'Delta', value: signed_delta, tooltip: "Delta = Future Plan (#{number(future_plan)}) + Actual (#{number(actual)}) - Target (#{number(target)})" } if target?),
      ].compact
    end

    def plan
      future_plan + actual
    end

    def target?
      target.positive?
    end

    private

    def number(value)
      ActiveSupport::NumberHelper.number_to_delimited(value)
    end

    def signed_delta
      delta.positive? ? "+#{number(delta)}" : number(delta)
    end
  end
end
