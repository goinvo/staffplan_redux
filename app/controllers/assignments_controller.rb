# frozen_string_literal: true

class AssignmentsController < RailsUiController
  def destroy
    assignment = current_company.assignments.find(params[:id])
    return head(:forbidden) unless assignment.removable_by?(current_user, manager: manager?)

    if assignment.destroy
      head :no_content
    else
      flash[:error] = assignment.errors.full_messages.to_sentence
      head :unprocessable_content
    end
  end

  def update
    assignment = current_company.assignments.find(params[:id])
    assignment.assign_attributes(assignment_params(assignment))

    if assignment.save
      flash[:highlight] = assignment.id if assignment.user_id_previously_changed?
    else
      flash[:error] = assignment.errors.full_messages.to_sentence
    end

    redirect_back_or_to (assignment.user ? person_path(assignment.user) : project_path(assignment.project)), status: :see_other
  end

  private

  def assignment_params(assignment)
    permitted = params.expect(assignment: %i[status focused user_id])
    permitted.delete(:status) unless [Assignment::ACTIVE, Assignment::PROPOSED].include?(permitted[:status])
    permitted.delete(:focused) unless assignment.user == current_user
    permitted.delete(:user_id) unless assignment.user_id.nil? && current_company.memberships.active.exists?(user_id: permitted[:user_id])
    permitted
  end
end
