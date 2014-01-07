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
  version '0.0.1'
  
  menu :top_menu, :time_check_in, { controller: 'user_time_checks', action: 'check_in' }, 
    caption: 'CHECK-IN', if: Proc.new {!UserTimeCheck.checked_in?(User.current.id)}, last: true
    menu :top_menu, :time_check_out, { controller: 'user_time_checks', action: 'check_out' }, 
      caption: 'CHECK-OUT', if: Proc.new {UserTimeCheck.checked_in?(User.current.id)}, last: true
  
      menu :top_menu, :user_leave_reports, { controller: 'user_leave_reports', action: 'index' }, caption: 'Leave Report'
  
      menu :top_menu, :user_time_checks, { controller: 'user_time_checks', action: 'index' }, caption: 'User Time Check'
  
      settings default: {'leave_types' => 'Annual, Sick, Unannounced',
        'default_type' => 'Unannounced',
      }, 
        partial: 'settings'
    end
