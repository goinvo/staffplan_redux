module Mutations
  class CreateWorkWeek < BaseMutation
    # arguments passed to the `resolve` method
    # argument :description, String, required: true
    # argument :url, String, required: true

    # return type from the mutation
    type Types::StaffPlan::WorkWeekType

    def resolve
      # TODO: implement
    end
  end
end