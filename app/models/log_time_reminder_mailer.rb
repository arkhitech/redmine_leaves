class LogTimeReminderMailer < ActionMailer::Base
  
  default from: 'timelog_reminder@redmine.com'
  
  def self.default_url_options
    Mailer.default_url_options
  end
  
  def reminder_email(user, issue, group, reminder)
    @user = user
    @issue = issue
    group_emails=[]
    unless group.empty?
      group_users = User.active.joins(:groups).
        where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => group)
      group_users.each do |user|
        group_emails << user.mail        
      end    
    end
    
    mail(to: @user.mail, subject: "#{reminder} #{l(:label_reminder_for_time_log)} #{@issue.id}",
      cc: group_emails)
  end
  
end