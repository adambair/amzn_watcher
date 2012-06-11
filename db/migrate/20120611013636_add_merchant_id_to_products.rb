class AddMerchantIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :merchant_id, :integer
  end
end
