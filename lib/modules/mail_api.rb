module MailApi
  include MailTemplate
  require 'mandrill'

  TEMPLATE_NAMES = {
      :new => 'mandrill_new_template',
      :updated => 'mandrill_updated_template',
      :approval => 'mandrill_approval_template',
      :completed => 'mandrill_completed_template'
  }


  def self.send_message(message_type, data)
    message_content = get_message_content(message_type, data)
    message_details = get_message_details(message_type,data)
    mandrill = self.establish_mandrill_connection
    result = mandrill.messages.send_template(TEMPLATE_NAMES[message_type.to_sym],message_content,message_details)
    log_results(result[0])
  end

  def self.get_message_details(message_type, data)
    subject = MailMessageDetails.new(message_type, data)
    subject.prepare
  end

  def self.get_message_content(message_type, data)
    content = MailPartialRenderer.new(message_type, data)
    template_content = MailTemplateContent.new(content.render, content.mail_type)
    template_content.prepare
  end

  def self.log_results(mail_result)
    if mail_result['status'] == 'sent'
      Rails.logger.info "Email message ID: #{mail_result['_id']} successfully sent to #{mail_result['email']}"
    else
      Rails.logger.info "Could not send message ID: #{mail_result['_id']} Reason listed: #{mail_result['reject_reason']}"
    end
  rescue => e
    Rails.logger.info "Failed to log message for email. Reason: #{e.message}"
  end


  def self.establish_mandrill_connection
    Mandrill::API.new(ENV['MANDRILL_APIKEY'])
  end
end