# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :delete_assignment, mutation: Mutations::DeleteAssignment
    field :delete_project, mutation: Mutations::DeleteProject
    field :set_current_company, mutation: Mutations::SetCurrentCompany
    field :upsert_assignment, mutation: Mutations::UpsertAssignment
    field :upsert_assignment_with_input, mutation: Mutations::UpsertAssignmentWithInput
    field :upsert_client, mutation: Mutations::UpsertClient
    field :upsert_client_with_input, mutation: Mutations::UpsertClientWithInput
    field :upsert_project, mutation: Mutations::UpsertProject
    field :upsert_project_with_input, mutation: Mutations::UpsertProjectWithInput
    field :upsert_work_week, mutation: Mutations::UpsertWorkWeek
    field :upsert_work_weeks, mutation: Mutations::UpsertWorkWeeks
  end
end
