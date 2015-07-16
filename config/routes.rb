resources :user_leaves
resources :user_leave_reports do
  collection do 
    get 'generate_report'
    post 'generate_report'
  end
end
#resources :user_leave_analytics
resources :user_time_checks, :only => [:index, :update, :edit] do
  collection { post :import }
end

resources :project, only: [] do
  resources :user_leaves do
  end
  resources :user_leave_reports do
    collection do
      get 'project_index'
      post 'project_index'
      get 'generate_report'
      post 'generate_report'
    end
  end
  
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


#match '/home', to: 'user_time_checks#home', via: 'get'
match '/check_in' => 'user_time_checks#check_in'
match '/check_out' => 'user_time_checks#check_out'
match '/checkout_timelog_success' => 'user_time_checks#checkout_timelog_success'
match '/user_leave_report' => 'user_leave_reports#report'

#match '/user_project_leave_report' => 'user_leave_reports#project_leaves_index'
#match '/user_leave_reportproject_report/:project_id' => 'user_leave_reports#project_report'
#match '/user_leave_reort/view_own_leaves' => 'user_leave_reports#view_own_leaves'
#match '/user_leave_report/add_own_leave' => 'user_leaves#add_own_leave'

match '/user_leave_analytics' => 'user_leave_analytics#report'
