namespace :my_namespace do
  desc "TODO"
  task :my_task1 => :environment do
   
    missing_timecheck_users = User.joins("LEFT OUTER JOIN #{TimeCheck.table_name} ON #{User.table_name}.id = #{TimeCheck.table_name}.user_id  AND check_in_time > #{Date.today.to_s}").where("user_id IS NULL")  

    missing_timecheck_users.each do |auto_leave|
      UserLeave.create(user_id: auto_leave.id, leave_type: Setting.plugin_tracker['default_type'], leave_date: Date.today)
    end

    #missing_timecheck_users = User.joins("LEFT OUTER JOIN #{TimeCheck.table_name} ON #{User.table_name}.id = #{TimeCheck.table_name}.user_id").where(["user_id IS NULL AND check_in_time > ?", DateTime.now])
    
############################################################################################
#    users   = User.all
#    users.each do |user|
#      user_timecheck_for_today = Timecheck.where(["user_id = ? and check_in_time > ?",
#          user.id, Date.today])
#      if user_timecheck_for_today.nil?
#        Userleaves.create!(user_id: user.id, leave_type: settings['leave_type_default'],
#          leave_date: Date.today)
#      end
############################################################################################
#      user_timechecks = Timecheck.where(user_id: user.id)
#      found_timecheck_for_today = false
#      user_timechecks.each do |timecheck|
#        
#          if(timecheck.check_in_time > Date.today)
#            found_timecheck_for_today = true
#            break
#            # user has checked in. so, do nothing              
#          end
#      end
#      unless found_timecheck_for_today
#        Userleaves.create!(user_id: user.id, leave_type: settings['leave_type_default'],
#          leave_date: Date.today)
#      end
############################################################################################
#   end
############################################################################################

  end

  desc "TODO"
  task :my_task2 => :environment do
  end
  
end
