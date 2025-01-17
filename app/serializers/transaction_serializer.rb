class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :status, :amount, :created_at, :address, :transaction_type, :proof_url, :email
  has_one :wallet
end
