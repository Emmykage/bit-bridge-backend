class OrderItemSerializer < ActiveModel::Serializer
  attributes :id, :quantity, :amount, :provision, :product
  belongs_to :product
  belongs_to :order_details
  belongs_to :provision
end
