class FixSystemGroupColumn < ActiveRecord::Migration
  def change
    rename_column :systems, :group, :category
  end
end
