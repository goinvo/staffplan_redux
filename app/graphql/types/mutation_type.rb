# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :set_current_company, mutation: Mutations::SetCurrentCompany
    field :upsert_work_week, mutation: Mutations::UpsertWorkWeek
    field :upsert_work_weeks, mutation: Mutations::UpsertWorkWeeks
    field :upsert_assignment, mutation: Mutations::UpsertAssignment
    field :upsert_project, mutation: Mutations::UpsertProject
    field :upsert_client, mutation: Mutations::UpsertClient
    field :delete_assignment, mutation: Mutations::DeleteAssignment
  end
end
