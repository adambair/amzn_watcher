class CreateMerchants < ActiveRecord::Migration
  def change
    create_table :merchants do |t|
      t.string :name
      t.integer :rating

      t.timestamps
    end
  end
end
