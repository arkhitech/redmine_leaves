require 'redmine'

Rails.configuration.to_prepare do
  require_dependency 'user'
  require_dependency 'redmine/helpers/calendar'
  
  User.send(:include, RedmineLeaves::Patches::UserPatch)
  Redmine::Helpers::Calendar.send(:include, RedmineLeaves::Patches::LeavesInCalendarPatch)
end  

require "#{File.join(File.dirname(__FILE__), 'config','wice_grid_config.rb')}"

Redmine::Plugin.register :redmine_leaves do
  name 'Redmine Leaves Plugin'
  author 'Arkhitech'
  description 'This is a plugin for user check-in/check-out'
  url 'http://github.com/arkhitech/redmine_leaves'
  author_url 'https://github.com/arkhitech'
  version '0.1.0'
   
  
  permission :view_time_reports, :user_time_check => :user_time_reporting
  
  
  menu :top_menu, :time_check_in, { controller: 'user_time_checks', action: 'check_in' }, 
    caption: :caption_top_menu_check_in, if: Proc.new {!UserTimeCheck.checked_in?(User.current.id)}, last: true
    menu :top_menu, :time_check_out, { controller: 'user_time_checks', action: 'check_out' }, 
      caption: :caption_top_menu_check_out, if: Proc.new {UserTimeCheck.checked_in?(User.current.id)}, last: true
  
      menu :top_menu, :user_leave_reports, { controller: 'user_leave_reports', action: 'index' }, caption: :caption_leave_report
  
      menu :top_menu, :user_time_checks, { controller: 'user_time_checks', action: 'index' }, caption: :caption_user_time_check
      
      menu :top_menu, :user_time_reporting, { controller: 'user_time_checks', action: 'user_time_reporting' }, :caption => 'User Time Reports'
      menu :user_time_report_menu, :user_time_report_custom, { :controller => 'user_time_checks', :action => 'user_time_reporting'}, :caption => 'Custom'
      menu :user_time_report_menu, :user_time_report_weekly, { :controller => 'user_time_checks', :action => 'user_time_reporting_weekly'}, :caption => 'Weekly'
      menu :user_time_report_menu, :user_time_report_monthly, { :controller => 'user_time_checks', :action => 'user_time_reporting_monthly'}, :caption => 'Monthly'
      
      menu :top_menu, :user_time_activity_report, { controller: 'user_time_checks', action: 'user_time_activity_report' }, :caption => 'User Time-Activity Report'
          menu :user_time_analytics_menu, :user_time_activity_report_custom, { :controller => 'user_time_checks', :action => 'user_time_activity_report'}, :caption => 'All Time'
      menu :user_time_analytics_menu, :user_time_activity_report_monthly, { :controller => 'user_time_checks', :action => 'user_time_activity_report_monthly'}, :caption => 'Monthly'
#  
       
      

  
       
       
      menu :leave_report_menu, :user_leave_reports, { :controller => 'user_leave_reports', :action => 'index' }, :caption => 'Overview'
      menu :leave_report_menu, :user_leaves, { :controller => 'user_leaves', :action => 'new' }, :caption => 'Add Leave'
      menu :leave_report_menu, :user_leave_analytics, { :controller => 'user_leave_analytics', :action => 'report'}, :caption => 'Analytics'
  
      settings default: {'leave_types' => 'Annual, Sick, Unannounced',
        'default_type' => 'Unannounced'}, partial: 'settings'
    end
