class AddCardHolderToCards < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :cards, :users rescue nil   # only if exists

    remove_column  :cards, :user_id, :uuid
    add_reference :cards, :card_holder, foreign_key: true, type: :uuid

    # Step 2: Backfill existing rows (make sure to set a valid card_holder_id)
    # Example: Assign a default card_holder for all existing cards:

    reversible do |dir|
      dir.up do
         default_card_holder = CardHolder.first
        if default_card_holder
            Card.update_all(card_holder_id: default_card_holder.id)
        else
          Card.delete_all
         end
      end
    end

    change_column_null :cards, :card_holder_id, false

  end
end
