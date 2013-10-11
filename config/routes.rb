resources :time_checks
resources :leave_summary

match '/checkin' => 'time_checks#checkin'
match '/checkout' => 'time_checks#checkout'

match '/report' => 'leave_summary#report'
match '/add_leave' => 'leave_summary#add_leave'
match '/add_leave_confirmation' => 'leave_summary#add_leave_confirmation'
