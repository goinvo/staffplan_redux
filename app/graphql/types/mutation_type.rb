# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :set_current_company, mutation: Mutations::SetCurrentCompany
    field :upsert_work_week, mutation: Mutations::UpsertWorkWeek
    field :upsert_assignment, mutation: Mutations::UpsertAssignment
  end
end
