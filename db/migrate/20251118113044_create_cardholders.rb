class CreateCardholders < ActiveRecord::Migration[7.1]
  def change
    create_table :cardholders, id: :uuid do |t|
      t.string :address
      t.string :postal_code
      t.string :bvn
      t.string :house_no
      t.string :city
      t.string :state
      t.jsonb :metadata
      t.references :wallet, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
