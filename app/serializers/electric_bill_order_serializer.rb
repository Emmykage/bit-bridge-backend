class ElectricBillOrderSerializer < ActiveModel::Serializer
  attributes :id, :billersCode, :amount, :request_id, :variation_code, :phone, :serviceID, :email, :type, :transaction_id, :status
end
