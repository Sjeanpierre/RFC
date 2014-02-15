class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.integer :change_id

      t.timestamps
    end
  end
end
