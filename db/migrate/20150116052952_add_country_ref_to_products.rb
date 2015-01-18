class AddCountryRefToProducts < ActiveRecord::Migration
  def change
    add_reference :products, :country, index: true
  end
end
