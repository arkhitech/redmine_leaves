resources :user_leaves
resources :user_leave_reports

match '/create_time_entries' => 'user_time_checks#create_time_entries'

match '/check_in' => 'user_time_checks#check_in'
match '/check_out' => 'user_time_checks#check_out'
match '/checkout_timelog_success' => 'user_time_checks#checkout_timelog_success'
match '/user_leave_report' => 'user_leave_reports#report'

