class Types::ClientAttributes < Types::BaseInputObject
  description "Attributes for creating or updating a client"
  argument :id, ID, required: false, description: "The ID of the client to update."
  argument :name, String, required: false, description: "The name of the client."
  argument :description, String, required: false, description: "The client's description."
  argument :status, String, required: false, description: "The status of the client."
end
