# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :timechecks
resources :leave_summary

match '/checkin' => 'timechecks#checkin'
match '/checkout' => 'timechecks#checkout'
