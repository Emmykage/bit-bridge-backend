class RenamePinEncryptedToPin < ActiveRecord::Migration[7.1]
  def change
    rename_column :cards, :pin_encrypted, :pin
  end
end
