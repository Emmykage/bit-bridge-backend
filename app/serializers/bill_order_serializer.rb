class BillOrderSerializer < ActiveModel::Serializer
  attributes :id, :status, :meter_number, :amount, :meter_type, :phone, :service_type, :payment_type, :email, :tariff_class, :name, :service_charge, :total_amount, :created_at
end