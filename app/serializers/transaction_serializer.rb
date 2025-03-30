class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :status, :amount, :created_at, :address, :bonus, :transaction_type, :proof_url, :email
  has_one :wallet
end
