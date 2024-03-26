module Mutations
  class SetCurrentCompany < BaseMutation
    argument :company_id, ID,
             required: true,
             description: "The ID of the company to set as the current user's current_company_id. User must be an active member of the company."

    # return type from the mutation
    type Types::StaffPlan::CompanyType

    def resolve(company_id:)
      user = context[:current_user]

      membership = user.
        memberships.
        active.
        find_by(company_id:)

      # user is not an active member of the company
      if membership.blank? || !membership.confirmed?
        raise GraphQL::ExecutionError, "Company not found."
      end

      user.update!(current_company: membership.company)

      user.current_company
    end
  end
end