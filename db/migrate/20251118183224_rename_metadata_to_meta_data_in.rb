class RenameMetadataToMetaDataIn < ActiveRecord::Migration[7.1]
  def change
    rename_column :card_holders, :metadata, :meta_data
    #Ex:- rename_column("admin_users", "pasword","hashed_pasword")
  end
end
