Redmine::Plugin.register :redmine_leaves do
  name 'Redmine Leaves Plugin'
  author 'Arkhitech'
  description 'This is a plugin for user check-in/check-out'
  version '1.0.0'
  
  menu :top_menu, :time_check_in, { controller: 'time_checks', action: 'checkin' }, 
    caption: 'CHECK-IN', if: Proc.new {!TimeCheck.checked_in?(User.current.id)}, last: true
  menu :top_menu, :time_check_out, { controller: 'time_checks', action: 'checkout' }, 
    caption: 'CHECK-OUT', if: Proc.new {TimeCheck.checked_in?(User.current.id)}, last: true
  
  menu :top_menu, :leave_summary, { controller: 'leave_summary', action: 'index' }, caption: 'Leave Summary'
  
  settings default: {'empty' => true}, partial: 'settings'
end
