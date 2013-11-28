resources :user_leaves
resources :user_leave_reports

match '/create_time_entries' => 'user_time_checks#create_time_entries'

get "user_time_checks/home"
get "user_time_checks/check_in"
get "user_time_checks/check_out"
get "user_time_checks/checkout_timelog_success"
 
match '/home', to: 'user_time_checks#home', via: 'get'
match '/check_in' => 'user_time_checks#check_in'
match '/check_out' => 'user_time_checks#check_out'
match '/checkout_timelog_success' => 'user_time_checks#checkout_timelog_success'
match '/user_leave_report' => 'user_leave_reports#report'

