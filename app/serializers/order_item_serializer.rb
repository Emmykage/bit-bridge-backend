class OrderItemSerializer < ActiveModel::Serializer
  attributes :id, :quantity, :amount
  has_one :product
  has_one :order_details
end
