class Country < ActiveRecord::Base
  belongs_to :product
  validates_uniqueness_of :name
  validates_presence_of :name
end