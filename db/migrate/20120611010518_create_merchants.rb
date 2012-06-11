class CreateMerchants < ActiveRecord::Migration
  def change
    create_table :merchants do |t|
      t.string :name
      t.integer :rating
      t.string :seller_id

      t.timestamps
    end
  end
end
