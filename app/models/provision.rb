class Provision < ApplicationRecord
  belongs_to :product
  enum :currency, {NGN: 0, USD: 1}

end
