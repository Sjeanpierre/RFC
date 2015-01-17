class Product < ActiveRecord::Base
  has_one :change
  belongs_to :country
  validates_presence_of :country_id, :name
  validates_uniqueness_of :name, :scope => :country


  def self.add_new(country,name)
    new(:name => name.downcase, :country => Country.find_or_create_by(:name => country)).save!
  end

  def self.list_for_dropdown
    grouped_by_country = includes(:country).all.to_a.group_by { |product| product.country }
    grouped_by_country.each do |_,product_list|
      product_list.map! { |product| {:id => product.id, :text => product.name.upcase} }
    end
    grouped_by_country.map { |product_country, product_name_array| {:text => product_country.name.upcase, :children => product_name_array} }
  end
end