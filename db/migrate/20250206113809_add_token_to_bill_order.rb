class AddTokenToBillOrder < ActiveRecord::Migration[7.1]
  def change
    add_column :bill_orders, :token, :string
  end
end
