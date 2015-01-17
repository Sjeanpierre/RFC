module MailTemplate

  MESSAGE_SECTIONS = {
      :Created => %W(title creator details link).map(&:to_sym),
      :Updated => %W(title creator details link).map(&:to_sym), #will need to remove sections
      :Approved => %W(title creator details link).map(&:to_sym),
      :Rejected => %W(title creator details link).map(&:to_sym),
      :Approval => %W(title creator details link).map(&:to_sym),
      :Completed => %W(title creator details link).map(&:to_sym),
      :Comment => %W(title creator comment_title comment link).map(&:to_sym)
  }
  SUBJECTS = {
      :Created => 'RFC %s has been %s',
      :Updated => 'RFC %s has been updated, %s',
      :Approved => 'RFC %s has been %s',
      :Rejected => 'RFC %s has been %s',
      :Completed => 'RFC %s has been %s',
      :approval => 'RFC %s requires your Approval',
      :completed => 'RFC %s has been %s',
      :Comment => '%s has commented on RFC %s'
  }
  VALUES = {
      :Created => %w(@data.id @event.details),
      :Updated => %w(@data.id @event.details),
      :Approved => %w(@data.id @event.details),
      :Rejected => %w(@data.id @event.details),
      :Completed => %w(@data.id @event.details),
      :approval => %w(@data.id),
      :completed => %w(@data.id @event.details), #needs to be user that marked as complete
      :Comment => %w(@event.user.name @data.id)
  }

  class MailPartialRenderer
    attr_accessor :mail_type, :content

    def initialize(mail_type, data, event)
      @data = data
      @event = event
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
    def initialize(mail_type, data, event)
      @mail_type = mail_type
      @data = data
      @event = event
    end

    def prepare
      {
          :from_name => APP_CONFIG['default_from_name'],
          :from_email => APP_CONFIG['default_from_email'],
          :subject => subject,
          :to => recipients,
          :auto_text => true,
      }
    end

    def subject
      #http://stackoverflow.com/a/554877/1317806
      values = MailTemplate::VALUES[@mail_type.to_sym].map { |val| eval(val) }
      sprintf(MailTemplate::SUBJECTS[@mail_type.to_sym], *values)
    end

    def recipients
      approver_emails = @data.approvers.map { |approver| { :email => approver.user.email, :name => approver.user.name } }
      approver_emails.push({ :email => @data.creator.email, :name => @data.creator.name })
      approver_emails.uniq
    end
  end
end