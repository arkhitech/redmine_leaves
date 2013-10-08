resources :time_checks
resources :leave_summary

match '/checkin' => 'time_checks#checkin'
match '/checkout' => 'time_checks#checkout'

match '/display' => 'leave_summary#display'
match '/report' => 'leave_summary#report'
