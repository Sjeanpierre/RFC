class AddImpactToChanges < ActiveRecord::Migration
  def change
    add_column :changes, :impact_id, :integer
  end
end
