class Product < ApplicationRecord
    has_one_attached :photo
    has_many :order_items
    enum :currency,  {NGN: 0, USD: 1}
    enum :category,  {"mobile provider" =>  0, "gift card" => 1,  service: 2 }


    def photo_url
        Rails.application.routes.url_helpers.url_for(photo) if photo.attached?
      end

end