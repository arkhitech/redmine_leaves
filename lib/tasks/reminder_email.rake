namespace :redmine_leaves do
  desc "Sends email to user who have not logged their time and are not marked as off"
  task :email_reminder_for_time_log, [:arg1] => :environment do |t, args|
    UserTimeCheck.email_reminder_for_issue_time_log
  end
  
  task report_time_logging_activity: :environment do
    UserTimeCheck.report_activity
  end
end
