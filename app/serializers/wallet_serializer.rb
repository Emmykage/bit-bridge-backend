class WalletSerializer < ActiveModel::Serializer
  attributes :id, :balance, :wallet_type, :total_bills, :withdrawn
  has_one :user
  has_many :transactions
end
