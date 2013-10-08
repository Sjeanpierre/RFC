class CreateChanges < ActiveRecord::Migration
  def change
    create_table :changes do |t|
      t.string :title
      t.text :summary
      t.text :impact
      t.text :rollback
      t.datetime :expected_change_date
      t.integer :priority_id
      t.integer :status_id
      t.integer :system_id
      t.integer :change_type_id

      t.timestamps
    end
  end
end
