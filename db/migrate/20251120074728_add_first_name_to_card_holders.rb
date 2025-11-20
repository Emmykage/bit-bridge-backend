class AddFirstNameToCardHolders < ActiveRecord::Migration[7.1]
  def change
    add_column :card_holders, :first_name, :string
    add_column :card_holders, :last_name, :string
  end
end
