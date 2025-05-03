class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :created_at, :admin, :reset_password_token, :role, :password
  has_one :wallet
  has_one :user_profile
  has_many :transactions
end
