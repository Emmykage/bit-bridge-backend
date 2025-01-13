class ProductSerializer < ActiveModel::Serializer
  attributes :id, :featured, :extra_info, :provider, :provision, :min_value, :max_value, :header_info, :description, :rate, :info, :attention, :notice_info, :category, :currency

  has_many :provisions
end