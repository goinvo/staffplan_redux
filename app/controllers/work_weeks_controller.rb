# frozen_string_literal: true

class WorkWeeksController < ApplicationController
  before_action :require_user!

  # POST /staffplans/:staffplan_id/work_weeks
  def create
    assignment = current_company.assignments.find(params.expect(work_week: [:assignment_id])[:assignment_id])
    @work_week = assignment.work_weeks.new(work_week_params)
    @work_week.save
  end

  # PATCH/PUT /staffplans/:staffplan_id/work_weeks/:id
  def update
    @work_week = current_company.work_weeks.find(params[:id])
    @work_week.update(work_week_params)
  end

  private

  def work_week_params
    params.expect(work_week: %i[estimated_hours actual_hours cweek year])
  end
end
