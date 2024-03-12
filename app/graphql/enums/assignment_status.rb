class Enums::AssignmentStatus < Types::BaseEnum
  value Assignment::PROPOSED, value: Assignment::PROPOSED.downcase, description: "The assignment has been proposed, but not yet started."
  value Assignment::ACTIVE, value: Assignment::ACTIVE.downcase, description: "The assignment is currently in progress."
  value Assignment::ARCHIVED, value: Assignment::ARCHIVED.downcase, description: "The assignment has been archived and is no longer in progress."
  value Assignment::COMPLETED, value: Assignment::COMPLETED.downcase, description: "The assignment has been completed."
end