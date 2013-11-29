every :weekday, :at => '12:01 pm' do
  rake "redmine_leaves:auto_leave_mark"
end

every :weekday, :at => '7:00 am' do
  rake "redmine_leaves:email_reminder_for_time_log"
end

#every :monday, :at => '7:00 am' do
#  rake "redmine_leaves:email_reminder_for_time_log[Setting.plugin_redmine_leaves['weekly_reminder']]"
#end
#
#every 1.month, :at=> 'start of the month at 7am' do
#  rake "redmine_leaves:email_reminder_for_time_log[Setting.plugin_redmine_leaves['monthly_reminder']]"
#end
