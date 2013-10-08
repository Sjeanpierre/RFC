class AddCreatedByToChange < ActiveRecord::Migration
  def change
    add_column :changes, :created_by, :integer
  end
end
