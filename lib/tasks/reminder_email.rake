namespace :redmine_leaves do
  desc "Sends email to user who have not logged their time and are not marked as off"
  task :email_reminder_for_time_log, [:arg1] => :environment do |t, args|

    cc_group = []
    reminder_time = ""
    
    if args.arg1 == "daily"
      cc_group = Setting.plugin_redmine_leaves['daily_reminder']
      reminder_time = "Daily"
    elsif args.arg1 == "weekly"
      cc_group = Setting.plugin_redmine_leaves['weekly_reminder']
      reminder_time = "Weekly"
    elsif args.arg1 == "monthly"
      cc_group = Setting.plugin_redmine_leaves['monthly_reminder']
      reminder_time = "Monthly"
    end
    
    all_users = User.active
    all_users.each do |user|
      assigned_issues= Issue.where(assigned_to_id: user.id).joins(:status).
        where("#{IssueStatus.table_name}.is_closed" => false)
      user_leave = UserLeave.where(user_id: user.id, leave_date: Date.today)
      assigned_issues.each do |issue|
        time_entry = TimeEntry.find_by_issue_id(issue)
        if time_entry.nil?
          #if user never logged time for this issue
          LogTimeReminderMailer.reminder_email(user, issue, cc_group, reminder_time).deliver          
        elsif !(time_entry.updated_on.to_date == Date.today) && user_leave.empty?
          #if user is present and did not log time today
          LogTimeReminderMailer.reminder_email(user, issue, cc_group, reminder_time).deliver
        end        
      end
    end
  end
end
