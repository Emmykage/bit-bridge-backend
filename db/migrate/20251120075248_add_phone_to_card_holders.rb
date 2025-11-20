class AddPhoneToCardHolders < ActiveRecord::Migration[7.1]
  def change
    add_column :card_holders, :phone, :string
  end
end
