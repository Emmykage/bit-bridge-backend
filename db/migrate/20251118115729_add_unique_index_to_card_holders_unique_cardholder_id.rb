class AddUniqueIndexToCardHoldersUniqueCardholderId < ActiveRecord::Migration[7.1]
  def change
    add_index :card_holders, :unique_card_holder_id, unique: true
















  end
end
