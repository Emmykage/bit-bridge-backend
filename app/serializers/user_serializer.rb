class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :created_at, :admin, :reset_password_token
  has_one :wallet
end
