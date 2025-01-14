class Provision < ApplicationRecord
  belongs_to :product
  has_many :order_items
  enum :currency,  {ngn: 0, usd: 1, gbp: 2, eur: 3}


end
