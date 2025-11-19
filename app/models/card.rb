# frozen_string_literal: true

class Card < ApplicationRecord
  belongs_to :card_holder
  has_one :wallet, through: :card_holder
end
