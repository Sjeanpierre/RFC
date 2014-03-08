paperclip_config = YAML.load_file(File.join(Rails.root, 'config', 'paperclip.yml'))[Rails.env]


Paperclip.interpolates :change  do |attachment, style|
  change_id = attachment.instance.change_id
  "RFC_#{change_id}"
end


Paperclip::Attachment.default_options.merge!({
    storage: :s3,
    :path => paperclip_config[:upload_path],
    :bucket => ENV['AWS_BUCKET'],
    :s3_permissions => :private,
    :s3_headers => {'Content-Disposition' => 'attachment'},
    s3_credentials: {
        :access_key_id => ENV['AWS_ACCESS_KEY'],
        :secret_access_key => ENV['AWS_SECRET_KEY']
    }
})