class OrderDetail < ApplicationRecord
    has_one_attached :proof
    belongs_to :user
    has_many :order_items
    validates :total_amount, presence: true,  numericality: {greater_than: 0}
    enum :order_type,  { buy: 0, sell: 1}
    enum :status,  {pending: 0, approved: 1, declined: 2}


    accepts_nested_attributes_for :order_items
    def proof_url
        Rails.application.routes.url_helpers.url_for(proof) if proof.attached?
      end
end
