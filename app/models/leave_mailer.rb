class LeaveMailer < ActionMailer::Base
  layout 'mailer'
  default from: Setting.mail_from
  def self.default_url_options
    Mailer.default_url_options
  end  
  def notify_absentee(user_leave)
    @leave = user_leave
    mail(to: @leave.user.mail, subject: I18n.t('subject_leave_marked_for', 
        fraction: @leave.default_fractional_leave_value, leave_date: I18n.l(@leave.leave_date)))
  end
  
  #send project timesheet
  def project_timesheet(user, timesheet_table, project, start_date, end_date)
    @timesheet_table = timesheet_table
    @report_date = start_date == end_date ? I18n.l(end_date) : "#{I18n.l(start_date)} - #{I18n.l(end_date)}"
    mail(to: user.mail, subject: I18n.t('subject_project_timesheet', 
      project: project, report_date: report_date))
  end

  def missing_time_log(user, start_date, end_date, logged_hours)
    @user = user
    @report_date = start_date == end_date ? I18n.l(end_date) : "#{I18n.l(start_date)} - #{I18n.l(end_date)}"
    @logged_hours = logged_hours
    mail(to: user.mail, subject: I18n.t('subject_missing_time_log', 
        user_name: user.name, report_date: @report_date))    
  end
  
end