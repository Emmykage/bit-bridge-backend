class TransactionRecordSerializer < ActiveModel::Serializer
  attributes :id, :transaction_id, :status, :paymentReference
end
