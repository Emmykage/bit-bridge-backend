class WalletSerializer < ActiveModel::Serializer
  attributes :id, :balance, :wallet_type, :total_bills, :withdrawn, :total_deposit
  has_one :user
  has_many :transactions
end
