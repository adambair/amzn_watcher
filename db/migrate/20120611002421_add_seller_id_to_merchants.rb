class AddSellerIdToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :seller_id, :bignum
  end
end
