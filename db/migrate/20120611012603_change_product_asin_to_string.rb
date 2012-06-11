class ChangeProductAsinToString < ActiveRecord::Migration
  def up
    change_table :products do |t|
      t.change :asin, :string
    end
  end

  def down
    change_table :products do |t|
      t.change :asin, :float
    end
  end
end
