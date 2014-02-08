class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.references :change
      t.string :event_type
      t.text :details

      t.timestamps
    end
    add_index :events, :change_id
  end
end