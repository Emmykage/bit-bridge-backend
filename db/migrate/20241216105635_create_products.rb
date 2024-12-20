class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products, id: :uuid do |t|
      t.boolean :integer, default: 0
      t.boolean :featured, default: false
      t.string :extra_info
      t.string :provider
      t.string :provision
      t.decimal :value
      t.text :header_info
      t.text :description
      t.integer :rating, default: 5
      t.text :notice_info
      t.text :alert_info
      t.decimal :value_max
      t.decimal :value_min

      t.timestamps
    end
  end
end
