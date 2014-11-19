class CurrentCompanyUsersSerializer < ActiveModel::Serializer
  root = false

  attributes :id, :full_name
end
