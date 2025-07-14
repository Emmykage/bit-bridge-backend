class UserProfile < ApplicationRecord
  belongs_to :user
   validates  :phone_number, uniqueness: true

end
