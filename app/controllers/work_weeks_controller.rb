# frozen_string_literal: true

class WorkWeeksController < ApplicationController
  before_action :require_user!
  before_action :set_work_week, only: %i[show edit update destroy]

  # POST /work_weeks or /work_weeks.json
  def create
    @work_week = WorkWeek.new(work_week_params)

    respond_to do |format|
      if @work_week.save
        format.html { redirect_to work_week_url(@work_week), notice: 'Work week was successfully created.' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /work_weeks/1 or /work_weeks/1.json
  def destroy
    @work_week.destroy!

    respond_to do |format|
      format.html { redirect_to work_weeks_url, notice: 'Work week was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /work_weeks/1/edit
  def edit; end

  # GET /work_weeks or /work_weeks.json
  def index
    @work_weeks = WorkWeek.all
  end

  # GET /work_weeks/new
  def new
    @work_week = WorkWeek.new
  end

  # GET /work_weeks/1 or /work_weeks/1.json
  def show; end

  # PATCH/PUT /work_weeks/1 or /work_weeks/1.json
  def update
    respond_to do |format|
      if @work_week.update(work_week_params)
        format.html { redirect_to work_week_url(@work_week), notice: 'Work week was successfully updated.' }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_work_week
    @work_week = WorkWeek.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def work_week_params
    params.expect(work_week: %i[estimated_hours actual_hours cweek year assignment_id])
  end
end
