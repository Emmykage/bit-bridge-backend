class OrderItem < ApplicationRecord
  belongs_to :product
  belongs_to :order_detail
  belongs_to :provision

  # validates :provision_id, presence: true


  validates :amount, numericality: { greater_than: 0 }
  validates :quantity, numericality: { greater_than: 0 }

end
