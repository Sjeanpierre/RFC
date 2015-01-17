class Product < ActiveRecord::Base
  has_one :change
  belongs_to :country
  validates_presence_of :country_id, :name
  validates_uniqueness_of :name, :scope => :country


  def self.add_new(country,name)
    new(:name => name.downcase, :country => Country.find_or_create_by(:name => country)).save!
  end
end