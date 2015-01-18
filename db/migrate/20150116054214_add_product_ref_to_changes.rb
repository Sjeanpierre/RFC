class AddProductRefToChanges < ActiveRecord::Migration
  def change
    add_reference :changes, :product, index: true
  end
end
