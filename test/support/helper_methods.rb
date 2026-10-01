# frozen_string_literal: true

# Helper methods for all tests
module TestHelperMethods
  # when the :work_weeks factory is used the user's current_company
  # is not the same as the one the project/assignment belongs to.
  def assignment_for_user(user:, status: Assignment::ACTIVE)
    client = create(:client, company: user.current_company)
    project = create(:project, client:)
    create(:assignment, user:, project:, status:)
  end

  def project_for_company(company)
    create(:project, client: create(:client, company:))
  end

  def tbd_assignment_for_company(company:)
    create(:assignment, :unassigned, project: project_for_company(company), status: Assignment::PROPOSED)
  end
end

# Include in all test classes
ActiveSupport.on_load(:active_support_test_case) { include TestHelperMethods }
ActiveSupport.on_load(:action_dispatch_integration_test) { include TestHelperMethods }
