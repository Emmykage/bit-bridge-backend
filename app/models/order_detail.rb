class OrderDetail < ApplicationRecord
    has_one_attached :proof
    belongs_to :user
    has_many :order_items
    has_many :card_tokens, through: :order_items
    has_many :provisions, through: :order_items
    # validates :total_amount, presence: true,  numericality: {greater_than: 0}
    enum :order_type,  { buy: 0, sell: 1}
    enum :payment_method,  { wallet: 0}
    enum :status,  {pending: 0, approved: 1, declined: 2}





    before_save :add_total
    accepts_nested_attributes_for :order_items



    def add_total
        self.total_amount = order_items.sum(&:amount) unless self.total_amount.present?
    end





    def proof_url
        Rails.application.routes.url_helpers.url_for(proof) if proof.attached?
      end
end
