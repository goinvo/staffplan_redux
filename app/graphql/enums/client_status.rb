class Enums::ClientStatus < Types::BaseEnum
  value Client::ACTIVE, value: Client::ACTIVE.downcase, description: "The client is active."
  value Client::ARCHIVED, value: Client::ARCHIVED.downcase, description: "The client is no longer active and should no longer be used."
end