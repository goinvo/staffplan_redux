class UserSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :url, :gravatar_url
end
