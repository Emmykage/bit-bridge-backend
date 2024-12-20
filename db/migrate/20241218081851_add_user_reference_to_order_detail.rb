class AddUserReferenceToOrderDetail < ActiveRecord::Migration[7.1]
  def change
    add_reference :order_details, :user, null: false, foreign_key: true, type: :uuid
  end
end
