class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :created_at, :admin
  has_one :wallet
end
