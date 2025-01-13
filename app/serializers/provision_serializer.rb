class ProvisionSerializer < ActiveModel::Serializer
  attributes :id, :name, :min_value, :value, :provision_value_type, :description
  has_one :product
end
