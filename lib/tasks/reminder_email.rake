namespace :redmine_leaves do
  desc "Sends email to user who have not logged their time and are not marked as off"
  task :email_reminder_for_time_log, [:arg1] => :environment do |t, args|
    
    rake_arg = args.arg1.split ' '
    rake_arg = Setting.plugin_redmine_leaves['daily_reminder']
    
    #NEED TO ADD A CONDITION FOR DAILY, WEEKLY AND MONTHLY REMINDER MAILS
    #WILL SET RECIPIENTS ACCORDINGLY (cc: )
    
    all_users = User.active
    all_users.each do |user|
      assigned_issues= Issue.where(assigned_to_id: user.id).joins(:status).
        where("#{IssueStatus.table_name}.is_closed" => false)
      user_leave = UserLeave.where(user_id: user.id, leave_date: Date.today)
      assigned_issues.each do |issue|
        time_entry = TimeEntry.find_by_issue_id(issue)
        if time_entry.nil?
          #if user never logged time for this issue
          LogTimeReminderMailer.reminder_email(user, issue, rake_arg).deliver          
        elsif !(time_entry.updated_on.to_date == Date.today) && user_leave.empty?
          #if user is present and did not logged time today
          LogTimeReminderMailer.reminder_email(user, issue, rake_arg).deliver
        end        
      end
    end
  end
end
