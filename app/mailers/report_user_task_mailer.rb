class ReportUserTaskMailer < ActionMailer::Base
  def report_task user_task, reporter
    @user_task = user_task
    @reporter = reporter
    sender = MailerConfig.config['info']
    receiver = MailerConfig.config['admin']
    mail to: receiver, subject: 'Beweis melden', from: sender, template_name: 'report_user_task'
  end
end

