namespace :redmine_leaves do
  task :auto_leave_mark => :environment do
   
    missing_timecheck_users = User.active.joins("LEFT OUTER JOIN #{UserTimeCheck.
      table_name} ON #{User.table_name}.id = #{UserTimeCheck.
      table_name}.user_id  AND check_in_time > #{Date.today.to_s}").where("user_id IS NULL")  

    missing_timecheck_users.each do |auto_leave|
      UserLeave.create(user_id: auto_leave.id, leave_type: Setting.plugin_redmine_leaves['default_type'],
        leave_date: Date.today)
    end

  end
end
