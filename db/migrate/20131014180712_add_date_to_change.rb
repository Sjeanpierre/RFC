class AddDateToChange < ActiveRecord::Migration
  def change
    add_column :changes, :change_date, :datetime
  end
end
