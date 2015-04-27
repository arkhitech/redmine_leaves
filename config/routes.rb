resources :user_leaves
resources :user_leave_reports
#resources :user_leave_analytics
resources :user_time_checks, :only => [:index, :update, :edit] do
  collection { post :import }
end

match '/create_time_entries' => 'user_time_checks#create_time_entries',  via: 'get'

get "user_time_checks/home"
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






match '/home', to: 'user_time_checks#home', via: 'get'
match '/check_in' => 'user_time_checks#check_in', via: 'get'
match '/check_out' => 'user_time_checks#check_out' ,via: 'get'
match '/checkout_timelog_success' => 'user_time_checks#checkout_timelog_success' ,via: 'get'
match '/user_leave_report' => 'user_leave_reports#report', via: [:get,:post]
match '/user_leave_analytics' => 'user_leave_analytics#report' ,via: [:get,:post]

