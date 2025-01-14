class ProvisionSerializer < ActiveModel::Serializer
  attributes :id, :name, :min_value, :max_value, :provision_value_type, :currency, :description
  has_one :product
  has_many :order_items
end
