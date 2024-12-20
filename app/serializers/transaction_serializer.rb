class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :status, :amount, :created_at, :address, :transaction_type
  has_one :wallet
end
