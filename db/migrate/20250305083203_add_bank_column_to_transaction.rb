class AddBankColumnToTransaction < ActiveRecord::Migration[7.1]
  def change
    add_column :transactions, :bank, :string
  end
end
