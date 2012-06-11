class Merchant < ActiveRecord::Base
  attr_accessible :name, :rating, :seller_id
  
  has_many :products, dependent: :destroy
  
  validates :seller_id, :presence => true
  validates_uniqueness_of :seller_id
  
  validates :name, :presence => true
  validates :rating, :presence => true
  
end
