# frozen_string_literal: true

class AssignmentsController < RailsUiController
  def update
    assignment = current_company.assignments.find(params[:id])
    assignment.assign_attributes(assignment_params(assignment))

    flash[:error] = assignment.errors.full_messages.to_sentence unless assignment.save

    redirect_back_or_to person_path(assignment.user), status: :see_other
  end

  private

  def assignment_params(assignment)
    permitted = params.expect(assignment: %i[status focused])
    permitted.delete(:status) unless [Assignment::ACTIVE, Assignment::PROPOSED].include?(permitted[:status])
    permitted.delete(:focused) unless assignment.user == current_user
    permitted
  end
end
