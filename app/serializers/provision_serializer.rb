class ProvisionSerializer < ActiveModel::Serializer
  attributes :id, :name, :min_value, :max_value, :provision_value_type
  has_one :product
end
