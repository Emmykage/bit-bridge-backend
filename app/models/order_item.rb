class OrderItem < ApplicationRecord
  belongs_to :product
  belongs_to :order_detail
  belongs_to :provision, optional: true

  validates :amount, numericality: { greater_than: 0 }

end
