resources :user_leaves
resources :user_leave_reports
#resources :user_leave_analytics
resources :user_time_checks, :only => [:index, :update, :edit] do
  collection { post :import }
end

match '/create_time_entries' => 'user_time_checks#create_time_entries'

#get "user_time_checks/home"
get "user_time_checks/check_in"
get "user_time_checks/check_out"
get "user_time_checks/checkout_timelog_success"
get "user_time_checks/user_time_reporting"
get "user_time_checks/user_time_reporting_weekly"
get "user_time_checks/user_time_reporting_monthly"
get "user_time_checks/user_time_activity_report"
post "user_time_checks/user_time_activity_report"
get "user_time_checks/user_time_activity_report_monthly"
post "user_time_checks/user_time_activity_report_monthly"


post "user_time_checks/user_time_activity_report_weekly"
get "user_time_checks/user_time_activity_report_weekly"




#match '/home', to: 'user_time_checks#home', via: 'get'
match '/check_in' => 'user_time_checks#check_in'
match '/check_out' => 'user_time_checks#check_out'
match '/checkout_timelog_success' => 'user_time_checks#checkout_timelog_success'
match '/user_leave_report' => 'user_leave_reports#report'
match '/user_leave_analytics' => 'user_leave_analytics#report'

