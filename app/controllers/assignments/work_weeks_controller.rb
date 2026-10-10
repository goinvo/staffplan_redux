# frozen_string_literal: true

module Assignments
  class WorkWeeksController < RailsUiController
    def fill_forward
      return head(:no_content) if work_week_params[:estimated_hours].blank?

      work_weeks = assignment.fill_forward(from: monday, through: through, estimated_hours: work_week_params[:estimated_hours])
      locked = work_weeks.count { it.errors.of_kind?(:base, :locked) }

      respond(("Unable to update #{locked} future work week(s) for an inactive user" if locked.positive?))
    end

    def update
      work_week = assignment.upsert_work_week(**work_week_params)

      respond(work_week.errors.full_messages.to_sentence)
    end

    private

    def assignment
      @assignment ||= current_company.assignments.find(params[:assignment_id])
    end

    def monday
      Date.commercial(work_week_params[:year].to_i, work_week_params[:cweek].to_i)
    rescue Date::Error
      raise ActionController::BadRequest
    end

    def respond(error)
      if error.present?
        flash[:error] = error
        head :unprocessable_content
      else
        head :no_content
      end
    end

    def through
      [Date.iso8601(params.expect(:through)), monday + (Timeline::Window::WEEK_COUNT - 1).weeks].min
    rescue Date::Error
      raise ActionController::BadRequest
    end

    def work_week_params
      @work_week_params ||= params.expect(work_week: %i[cweek year estimated_hours actual_hours]).to_h.symbolize_keys
    end
  end
end
