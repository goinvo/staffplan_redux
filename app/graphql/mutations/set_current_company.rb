module Mutations
  class SetCurrentCompany < BaseMutation
    # arguments passed to the `resolve` method
    argument :company_id, ID, required: true

    # return type from the mutation
    type Types::StaffPlan::CompanyType

    def resolve
      # TODO: implement
    end
  end
end