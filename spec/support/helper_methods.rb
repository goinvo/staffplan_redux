# when the :work_weeks factory is used the user's current_company
# is not the same as the one the project/assignment belongs to.
def assignment_for_user(user:, status: Assignment::ACTIVE)
  client = create(:client, company: user.current_company)
  project = create(:project, client:)
  create(:assignment, user:, project:, status:)
end

def tbd_assignment_for_company(company:)
  client = create(:client, company: company)
  project = create(:project, client:)
  create(:assignment, :unassigned, project:, status: Assignment::PROPOSED)
end
