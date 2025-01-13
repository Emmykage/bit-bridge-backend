class OrderItemSerializer < ActiveModel::Serializer
  attributes :id, :quantity, :amount, :provision, :product
  has_one :product
  has_one :order_details
  belongs_to :provision
end
