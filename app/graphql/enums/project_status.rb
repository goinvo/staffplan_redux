class Enums::ProjectStatus < Types::BaseEnum
  value Project::PROPOSED, value: Project::PROPOSED.downcase, description: "The project is proposed."
  value Project::ACTIVE, value: Project::ACTIVE.downcase, description: "The project is active."
  value Project::ARCHIVED, value: Project::ARCHIVED.downcase, description: "The project is archived and is no longer active."
  value Project::CANCELLED, value: Project::CANCELLED.downcase, description: "The project is canceled."
  value Project::COMPLETED, value: Project::COMPLETED.downcase, description: "The project is completed."
end
