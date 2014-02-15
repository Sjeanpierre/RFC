class AddPaperclipToAttachment < ActiveRecord::Migration
  def change
    add_column :attachments, :attachment_file_name, :string
    add_column :attachments, :attachment_content_type, :string
    add_column :attachments, :attachment_file_size, :integer
  end
end
