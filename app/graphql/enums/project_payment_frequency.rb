class Enums::ProjectPaymentFrequency < Types::BaseEnum
  value Project::WEEKLY, value: Project::WEEKLY.downcase, description: "The project is paid weekly."
  value Project::MONTHLY, value: Project::MONTHLY.downcase, description: "The project is paid monthly."
  value Project::FORTNIGHTLY, value: Project::FORTNIGHTLY.downcase, description: "The project is paid fortnightly."
  value Project::QUARTERLY, value: Project::QUARTERLY.downcase, description: "The project is paid quarterly."
  value Project::ANNUALLY, value: Project::ANNUALLY.downcase, description: "The project is paid annually."
end
