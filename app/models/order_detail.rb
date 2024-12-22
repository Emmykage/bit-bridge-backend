class OrderDetail < ApplicationRecord

    belongs_to :user
    has_many :order_items
    validates :total_amount, presence: true,  numericality: {greater_than: 0}



    accepts_nested_attributes_for :order_items

end
