module MailApi
  include MailTemplate
  require 'mandrill'

  class Sender

    TEMPLATE_NAMES = {
        :Created => 'mandrill_created_template',
        :Updated => 'mandrill_updated_template',
        :Approval => 'mandrill_approvers_template',
        :Completed => 'mandrill_approval_status_template',
        :Rejected => 'mandrill_approval_status_template',
        :Approved => 'mandrill_approval_status_template',
        :Comment => 'mandrill_commented_template',
    }

    def initialize(message_type, data, event)
      @message_type = message_type
      @change = data
      @event = event
    end

    def send_message
      message_content = get_message_content
      message_details = get_message_details
      mandrill = self.establish_mandrill_connection
      result = mandrill.messages.send_template(TEMPLATE_NAMES[@message_type.to_sym], message_content, message_details)
      log_results(result[0])
    end

    def get_message_details
      subject = MailTemplate::MailMessageDetails.new(@message_type, @change, @event)
      subject.prepare
    end

    def get_message_content
      content = MailTemplate::MailPartialRenderer.new(@message_type, @change, @event)
      template_content = MailTemplate::MailTemplateContent.new(content.render, content.mail_type)
      template_content.prepare
    end

    def log_results(mail_result)
      if mail_result['status'] == 'sent'
        Rails.logger.info "Email message ID: #{mail_result['_id']} successfully sent to #{mail_result['email']}"
      else
        Rails.logger.info "Could not send message ID: #{mail_result['_id']} Reason listed: #{mail_result['reject_reason']}"
      end
    rescue => e
      Rails.logger.info "Failed to log message for email. Reason: #{e.message}"
    end


    def establish_mandrill_connection
      Mandrill::API.new(ENV['MANDRILL_APIKEY'])
    end

  end

end