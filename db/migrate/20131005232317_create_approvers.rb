class CreateApprovers < ActiveRecord::Migration
  def change
    create_table :approvers do |t|
      t.references :user, index: true
      t.references :change, index: true
      t.boolean :approved

      t.timestamps
    end
  end
end
