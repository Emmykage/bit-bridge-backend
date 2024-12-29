class OrderDetailSerializer < ActiveModel::Serializer
  attributes :id, :order_type, :total_amount, :status, :payment_method, :viewed, :net_total
end
