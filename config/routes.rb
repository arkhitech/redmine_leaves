resources :time_checks
resources :leave_summary
resources :leaves

match '/checkin' => 'time_checks#checkin'
match '/checkout' => 'time_checks#checkout'

match '/report' => 'leave_summary#report'
