class Product < ActiveRecord::Base
  attr_accessible :asin, :condition, :name, :price, :shipping_price

  belongs_to :merchant
  
  validates :asin, :presence => true
  validates :condition, :presence => true
  validates :price, :presence => true
  validates :shipping_price, :presence => true
  
end