class CardTokenSerializer < ActiveModel::Serializer
  attributes :id, :reveal, :token
  belongs_to :order_item
end
