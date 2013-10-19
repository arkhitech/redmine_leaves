resources :user_time_checks
resources :user_leaves
resources :user_leave_reports

match '/check_in' => 'user_time_checks#check_in'
match '/check_out' => 'user_time_checks#check_out'

match '/user_leave_report' => 'user_leave_reports#report'
