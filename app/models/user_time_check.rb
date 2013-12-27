class UserTimeCheck < ActiveRecord::Base
  unloadable
  class << self
    def checked_in?(user_id)
      exists?(['user_id = ? and check_out_time IS NULL', user_id])
    end
  end
  def self.import(file)
    unless file.nil?
      CSV.foreach(file.path, headers: true) do |row|      
        name = row["Name"]
        date = row["Date"].to_datetime
        user = User.find_by_firstname(name.split(" ").first)
       
        if user
          checkin_timechecks = UserTimeCheck.
            where(['user_id = ? AND check_in_time < ? AND check_in_time > ? AND check_out_time IS NULL', 
              user.id, date.end_of_day, date.beginning_of_day])

          if checkin_timechecks.empty?
            UserTimeCheck.create(user_id: user.id, check_in_time: date)
          else
            user_time_check = checkin_timechecks.first
            checked_time = date.to_time - user_time_check.check_in_time.to_time
            difference = Time.at(checked_time).utc.strftime("%H").to_i
            if difference > 1 && difference < 16
              user_time_check.update_attributes(check_out_time: date)
            elsif difference > 16
              user_time_check.update_attributes(check_out_time: user_time_check.check_in_time + 4.hours, 
                comments: 'Auto-Generated Check-Out')
              UserTimeCheck.create(user_id: user.id, check_in_time: date)
            else
              #ignore the check-in
            end
          end
        end
      end
    end
  end
end
