class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.float :price
      t.float :shipping_price
      t.float :asin
      t.string :condition

      t.timestamps
    end
  end
end
