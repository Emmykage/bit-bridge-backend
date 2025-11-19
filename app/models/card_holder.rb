class CardHolder < ApplicationRecord
  belongs_to :wallet
  has_many :cards, dependent: :destroy
  validates :unique_card_holder_id, presence: true, uniqueness: true


  def created_cards
  cards.where.not(card_id: nil)

  end
end
