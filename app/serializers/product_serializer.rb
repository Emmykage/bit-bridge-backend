class ProductSerializer < ActiveModel::Serializer
  attributes :id, :product_type, :featured, :extra_info, :provider, :provision, :value, :header_info, :description, :rating, :notice_info, :alert_info, :value_max, :value_min
end
