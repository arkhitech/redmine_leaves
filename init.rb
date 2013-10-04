Redmine::Plugin.register :tracker do
  name 'Tracker plugin'
  author 'Abuzar Hasan'
  description 'This is a plugin for user check-in/check-out'
  version '1.0.0'
  
  menu :top_menu, :timechecks, { :controller => 'timechecks', :action => 'index' }, :caption => 'Check-in/Check-out'
  menu :top_menu, :leave_summary, { :controller => 'leave_summary', :action => 'index' }, :caption => 'Leave Summary'
  
  settings :default => {'empty' => true}, :partial => 'settings'
end
