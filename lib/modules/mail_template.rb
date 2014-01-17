module MailTemplate

  MESSAGE_SECTIONS = {
      :new => %W(title details link).map(&:to_sym),
      :update => %W(title details summary rollback).map(&:to_sym), #will need to remove sections
      :approval => %W(title approvers).map(&:to_sym),
      :completed => %W(title details summary rollback notes).map(&:to_sym)
  }

  class MailPartialRenderer
    attr_accessor :mail_type, :content

    def initialize(mail_type, data)
      @data = data
      @template_sections = MailTemplate::MESSAGE_SECTIONS[mail_type.to_sym]
      @mail_type = mail_type
      @content = nil
    end

    def render
      rendered_templates_struct = Struct.new(*@template_sections)
      rendered_templates = rendered_templates_struct.new
      @template_sections.each do |template_section|
        template_contents = File.read(Rails.root.join('lib', 'mail_templates', "#{template_section.to_s}.erb"))
        rendered_templates[template_section] = erb_handler(template_contents)
      end
      @content = rendered_templates
    end

    private
    def erb_handler(template)
      erb_template = ERB.new(template)
      erb_template.result(binding)
    end
  end

  class MailTemplateContent
    attr_accessor :formatted

    def initialize(rendered_content, mail_type)
      @rendered_content = rendered_content
      @template_names = MailTemplate::MESSAGE_SECTIONS[mail_type.to_sym]
    end

    def prepare
      formatted = Array.new
      @template_names.each do |template_name|
        section_html = @rendered_content[template_name]
        formatted.push({ :content => section_html, :name => template_name.to_s })
      end
      @formatted = formatted
    end
  end

  class MailMessageDetails
    SUBJECTS = {
        :new => 'RFC %s has been created by %s',
        :update => 'RFC %s has been updated by %s',
        :approval => 'Your Approval is needed for RFC %s',
        :completed => 'RFC %s has been marked as completed by %s'
    }
    VALUES = {
        :new => %w(@data.id @data.creator.name),
        :update => %w(@data.id @data.creator),
        :approval => %w(@data.id),
        :completed => %w(@data.id @data.creator) #needs to be user that marked as complete
    }

    def initialize(mail_type, data)
      @mail_type = mail_type
      @data = data
    end

    def prepare
      {
          :from_name => 'RFchange',
          :from_email => 'sender@computersolutions3.com',
          :subject => subject,
          :to => recipients,
          :auto_text => true,

      }
    end

    def subject
      #http://stackoverflow.com/a/554877/1317806
      values = VALUES[@mail_type.to_sym].map { |val| eval(val) }
      sprintf(SUBJECTS[@mail_type.to_sym], *values)
    end

    def recipients
      return [{ :email => 'sjp@mailinator.com', :name => 'Tommy Jones'}]
      approver_emails = @data.approvers.map { |approver| { 'email' => approver.email, 'name' => approver.name } }
      approver_emails.push({ :email => @data.creator.email, :name => @data.creator.name })
    end
  end
end