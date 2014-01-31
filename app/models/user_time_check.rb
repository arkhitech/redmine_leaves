class UserTimeCheck < ActiveRecord::Base
  unloadable
  belongs_to :user
  
  validates :check_in_time, :check_out_time, :presence=> true,:on => :update
  validate :correctness_of_user_time_checks
  
  class << self
    def checked_in?(user_id)
      exists?(['user_id = ? and check_out_time IS NULL', user_id])
    end
  end
  
  INDEX_ZK_NAME = 4
  INDEX_ZK_DATETIME = 1
  
  def self.import(file, options = {:headers => false, :col_sep => "\t"} )
    unless file.nil?
      CSV.foreach(file.path, options) do |row|      
        name = row[INDEX_ZK_NAME]
        date = row[INDEX_ZK_DATETIME]
        user = User.find_by_firstname(name.split(" ").first)
        
        unless name && date && user
          # missing name or date or no records found in database
          next
        end
        
        date = date.to_datetime
        
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
              comments: l(:auto_generated_comment))
            UserTimeCheck.create(user_id: user.id, check_in_time: date)
          else
            #ignore the check-in
          end
        end        
      end
    end
  end
  def correctness_of_user_time_checks
    unless check_in_time.nil? || check_out_time.nil?
      if check_in_time > check_out_time
        errors.add(:check_in_time, ": cannot be greater than Check-Out Time")
      end   
    end
  end
end
