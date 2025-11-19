# frozen_string_literal: true

class CardHolderSerializer < ActiveModel::Serializer
  attributes :id, :unique_card_holder_id, :meta_data,  :state, :cards, :created_cards
  has_one :wallet
  has_many :cards
end
