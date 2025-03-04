class BillOrderSerializer < ActiveModel::Serializer
  attributes :id, :status, :meter_number, :amount, :meter_type, :phone, :serviceID, :service_type, :payment_type, :email, :tariff_class, :name, :service_charge
end