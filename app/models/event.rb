class Event < ActiveRecord::Base
  belongs_to :change
  after_commit :send_mail, :unless => Proc.new { SKIP_CALLBACKS }


  def send_mail
    mailer = MailApi::Sender.new(self.event_type, self.change, self)
    mailer.send_message
  end

end