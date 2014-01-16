class LeaveMailer < ActionMailer::Base
  layout 'mailer'
  default from: Setting.mail_from
  def self.default_url_options
    Mailer.default_url_options
  end  
  def notify_absentee(user_leave)
    @leave=user_leave
#    puts "on successful save it returns #{@leave.leave_type},for #{@leave.user}"
    mail(to: @leave.user.mail, subject: "#{l(:label_leave_marked_for)} #{@leave.leave_date}")
  end
end