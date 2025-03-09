class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :created_at, :admin, :reset_password_token, :role
  has_one :wallet
  has_many :transactions
end
