class WorkWeeksController < ApplicationController
  before_action :require_user!
  before_action :set_work_week, only: %i[ show edit update destroy ]

  # GET /work_weeks or /work_weeks.json
  def index
    @work_weeks = WorkWeek.all
  end

  # GET /work_weeks/1 or /work_weeks/1.json
  def show
  end

  # GET /work_weeks/new
  def new
    @work_week = WorkWeek.new
  end

  # GET /work_weeks/1/edit
  def edit
  end

  # POST /work_weeks or /work_weeks.json
  def create
    @work_week = WorkWeek.new(work_week_params)

    respond_to do |format|
      if @work_week.save
        format.html { redirect_to work_week_url(@work_week), notice: "Work week was successfully created." }
        format.json { render :show, status: :created, location: @work_week }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @work_week.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /work_weeks/1 or /work_weeks/1.json
  def update
    respond_to do |format|
      if @work_week.update(work_week_params)
        format.html { redirect_to work_week_url(@work_week), notice: "Work week was successfully updated." }
        format.json { render :show, status: :ok, location: @work_week }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @work_week.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /work_weeks/1 or /work_weeks/1.json
  def destroy
    @work_week.destroy!

    respond_to do |format|
      format.html { redirect_to work_weeks_url, notice: "Work week was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_work_week
      @work_week = WorkWeek.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def work_week_params
      params.require(:work_week).permit(:estimated_hours, :actual_hours, :cweek, :year, :assignment_id, :beginning_of_week)
    end
end
