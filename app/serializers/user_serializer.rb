# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :created_at, :admin, :reset_password_token, :role, :password, :active
  has_one :wallet
  has_many :bill_orders
  has_one :user_profile
  has_many :transactions
  has_many :accounts
end
