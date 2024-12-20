class OrderDetailSerializer < ActiveModel::Serializer
  attributes :id, :total_amount, :status, :payment_method, :viewed, :net_total
end
