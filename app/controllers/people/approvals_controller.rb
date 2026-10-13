# frozen_string_literal: true

module People
  class ApprovalsController < RailsUiController
    def create
      user = current_company.users.find(params[:person_id])
      return head(:forbidden) if user != current_user || user.inactive?(company: current_company)

      approval = HoursApproval.new(assignments: user.assignments.where(focused: true, project: current_company.projects.where.not(status: Project::ARCHIVED)), monday:)
      flash[:error] = approval.errors.full_messages.to_sentence unless approval.save

      redirect_back_or_to person_path(user), status: :see_other
    end

    private

    def monday
      Date.iso8601(params.expect(:week)).beginning_of_week(:monday)
    rescue Date::Error
      raise ActionController::BadRequest
    end
  end
end
