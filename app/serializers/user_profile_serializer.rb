# frozen_string_literal: true

class UserProfileSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :phone_number
  has_one :user
end
