class LeaveMailer < ActionMailer::Base
  layout 'mailer'
  default from: Setting.mail_from
  helper ApplicationHelper
  def self.default_url_options
    Mailer.default_url_options
  end  
  def cc_email_addresses
    User.in_group(UserTimeCheck.time_log_receivers_group).map(&:mail)    
  end
  private :cc_email_addresses
  
  def notify_absentee(user_leave)
    @total_yearly_leaves = UserLeave.where(user_id: user_leave.user_id, leave_type: user_leave.leave_type).where("leave_date >= ?", Date.today.beginning_of_year).sum(:fractional_leave)
    @leave = user_leave
    mail(to: @leave.user.mail, 
      cc: cc_email_addresses,
      subject: I18n.t('subject_leave_marked_for', 
        user_name: @leave.user.name,
        fraction: @leave.fractional_leave, total_yearly_leaves: @total_yearly_leaves,
        leave_type: @leave.leave_type, leave_date: I18n.l(@leave.leave_date)))
  end
  
  #send project timesheet
  def project_timesheet(users, timesheet_table, project, start_date, end_date)
    @timesheet_table = timesheet_table
    @report_date = start_date == end_date ? I18n.l(end_date) : "#{I18n.l(start_date)} - #{I18n.l(end_date)}"
    mail(to: users.map(&:mail), subject: I18n.t('subject_project_timesheet', 
      project: project, report_date: @report_date))
  end

  def group_timesheet(users, timesheet_table, group, start_date, end_date)
    @timesheet_table = timesheet_table
    @report_date = start_date == end_date ? I18n.l(end_date) : "#{I18n.l(start_date)} - #{I18n.l(end_date)}"
    mail(to: users.map(&:mail), subject: I18n.t('subject_group_timesheet', 
      group: group.lastname, report_date: @report_date))
  end
  
  def missing_time_log(user, start_date, end_date, logged_hours)
    @user = user
    @report_date = start_date == end_date ? I18n.l(end_date) : "#{I18n.l(start_date)} - #{I18n.l(end_date)}"
    @logged_hours = logged_hours
    mail(to: user.mail, 
      cc: cc_email_addresses,
      subject: I18n.t('subject_missing_time_log', 
        user_name: user.name, report_date: @report_date))    
  end
  
end