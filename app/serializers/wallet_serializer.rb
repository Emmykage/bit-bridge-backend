class WalletSerializer < ActiveModel::Serializer
  attributes :id, :balance, :wallet_type
  has_one :user
  has_many :transactions
end
