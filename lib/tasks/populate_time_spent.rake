namespace :redmine_leaves do
  task populate_time_spent: :environment do
   
    missing_timespent = UserTimeCheck.where("time_spent is NULL and check_out_time is NOT NULL")
    unless missing_timespent.blank?
      missing_timespent.each do |missing|    
        checked_time = missing.check_out_time.to_time - missing.check_in_time.to_time
        missing.update_attributes(time_spent: checked_time/60)
              
      end
    end
  end
end

