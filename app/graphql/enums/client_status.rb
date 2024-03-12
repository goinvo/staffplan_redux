class Enums::ClientStatus < Types::BaseEnum
  value Assignment::ACTIVE, value: Client::ACTIVE.downcase, description: "The client is active."
  value Assignment::ARCHIVED, value: Client::ARCHIVED.downcase, description: "The client is no longer active and should no longer be used."
end