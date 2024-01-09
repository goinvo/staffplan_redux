# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :set_current_company, mutation: Mutations::SetCurrentCompany
    field :update_work_week, mutation: Mutations::UpsertWorkWeek
  end
end
