class Attachment < ActiveRecord::Base
  belongs_to :change
  has_attached_file :attachment


  def file_extension
    filename = attachment_file_name
    extension = filename.split('.').last
    return 'NIL' if filename == extension
    extension.split(//).last(4).join('').to_s.upcase
  end
end
