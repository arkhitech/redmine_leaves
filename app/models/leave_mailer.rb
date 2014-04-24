class LeaveMailer < ActionMailer::Base
  layout 'mailer'
  default from: Setting.mail_from
  def self.default_url_options
    Mailer.default_url_options
  end  
  def notify_absentee(user_leave)
    @leave=user_leave
    mail(to: @leave.user.mail, subject: "#{I18n.t("label_leave_marked_for")} #{@leave.leave_date}")
  end
end