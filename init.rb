require 'redmine'
Rails.configuration.to_prepare do
  require_dependency 'user'
  require_dependency 'redmine/helpers/calendar'
  
  User.send(:include, RedmineLeaves::Patches::UserPatch)
  Redmine::Helpers::Calendar.send(:include, RedmineLeaves::Patches::LeavesInCalendarPatch)
end  

Redmine::Plugin.register :redmine_leaves do
  name 'Redmine Leaves Plugin'
  author 'Arkhitech'
  description 'This is a plugin for user check-in/check-out'
  url 'http://github.com/arkhitech/redmine_leaves'
  author_url 'https://github.com/arkhitech'
  version '0.1.0'
      
  menu :top_menu, :time_check_in, { controller: 'user_time_checks', action: 'check_in' }, 
    caption: :caption_top_menu_check_in, if: Proc.new {!UserTimeCheck.checked_in?(User.current.id)}, last: true
  menu :top_menu, :time_check_out, { controller: 'user_time_checks', action: 'check_out' }, 
    caption: :caption_top_menu_check_out, if: Proc.new {UserTimeCheck.checked_in?(User.current.id)}, last: true
  
  menu :top_menu, :user_leave_reports, { controller: 'user_leave_reports', action: 'index' }, caption: :caption_leave_report
  
  menu :top_menu, :user_time_checks, { controller: 'user_time_checks', action: 'index' }, caption: :caption_user_time_check
  
  menu :leave_report_menu, :user_leave_reports, { :controller => 'user_leave_reports', :action => 'index' }, :caption => 'Overview'
  menu :leave_report_menu, :user_leaves, { :controller => 'user_leaves', :action => 'new' }, :caption => 'Add Leave'
  menu :leave_report_menu, :user_leave_analytics, { :controller => 'user_leave_analytics', :action => 'report'}, :caption => 'Analytics'
  
  settings default: {'leave_types' => 'Annual, Sick, Unannounced',
    'working_days' => ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
    'default_type' => 'Unannounced', }, partial: 'settings'
end
