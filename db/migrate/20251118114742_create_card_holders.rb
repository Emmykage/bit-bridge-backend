class CreateCardHolders < ActiveRecord::Migration[7.1]
  def change
    create_table :card_holders, id: :uuid do |t|
      t.string :address
      t.string :postal_code
      t.string :bvn
      t.string :house_no
      t.string :city
      t.string :state
      t.jsonb :metadata
      t.references :wallet, null: false, foreign_key: true, type: :uuid
      t.string :unique_card_holder_id

      t.timestamps
    end
  end
end
