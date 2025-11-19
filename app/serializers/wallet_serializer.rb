# frozen_string_literal: true

class WalletSerializer < ActiveModel::Serializer
  attributes :id, :balance, :wallet_type, :total_bills, :withdrawn, :total_deposit, :commission
  has_one :user
  has_one :card_holder
  has_many :transactions
end
