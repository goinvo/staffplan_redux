# frozen_string_literal: true

module People
  class AssignmentsController < RailsUiController
    def create
      user = current_company.users.find(params[:person_id])
      return head(:forbidden) if user.inactive?(company: current_company)

      proposal = ProposedAssignment.new(company: current_company, user:, **params.expect(proposed_assignment: %i[client_name project_name]))

      if proposal.save
        flash[:highlight] = proposal.assignment.id
        redirect_back_or_to person_path(user), status: :see_other
      else
        render turbo_stream: turbo_stream.replace('add_project', People::AddProjectRowComponent.new(user:, company: current_company, proposal:, open: true)),
               status: :unprocessable_content
      end
    end
  end
end
