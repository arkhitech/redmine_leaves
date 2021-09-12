class LogTimeReminderMailer < ActionMailer::Base
  
  default from: 'timelog_reminder@redmine.com'
  
  def self.default_url_options
    ::Mailer.default_url_options
  end
  
  def reminder_email(user, issue, cc_group, reminder, cc_emails = [])
    @user = user
    @issue = issue
    cc_emails = []
    unless cc_group.empty?
      cc_group_users = User.active.joins(:groups).
        where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => group)
      cc_group_users.each do |user|
        cc_emails << user.mail        
      end    
    end
    
    mail(to: @user.mail, subject: "#{reminder} #{t(:label_reminder_for_time_log)} #{@issue.id}",
      cc: cc_emails)
  end
  
end