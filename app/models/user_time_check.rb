class UserTimeCheck < ActiveRecord::Base
  unloadable
  belongs_to :user
  
  validates :time_spent,:check_in_time, :check_out_time, :presence=> true,:on => :update
  validate :correctness_of_user_time_checks
  
  class << self
    def checked_in?(user_id)
      exists?(['user_id = ? and check_out_time IS NULL', user_id])
    end
  end
  
  INDEX_ZK_NAME = 4
  INDEX_ZK_DATETIME = 1
  
  
  def self.as_csv
    
    CSV.generate do |csv|
      csv << ["USER ID", "User Name", "Check In Time", "Check Out Time ", "Time Spent", "Comments"] ## Header values of CSV
      all.each do |emp|
        csv << [emp.user_id, emp.user.name, emp.check_in_time, emp.check_in_time, emp.time_spent, emp.comments] ##Row values of CSV
      end
    end
  end


  def self.autogenerate_checkout(missed_checkout)
    if missed_checkout.check_in_time.hour < 16
      missed_checkout.update_attributes(check_out_time: missed_checkout.check_in_time + 6.hours, 
        comments: l(:auto_generated_comment),time_spent: 6*60)
    else
      #consider previously marked check_in_time as actually check_out time
      missed_checkout.update_attributes(check_in_time: missed_checkout.check_in_time - 6.hours, 
        check_out_time: missed_checkout.check_in_time,
        comments: l(:auto_generated_comment),time_spent: 6*60)

    end
  end
  
  def self.import(file, options = {:headers => false, :col_sep => "\t"} )
    unless file.nil?
      CSV.foreach(file.path, options) do |row|      
        name = row[INDEX_ZK_NAME]
        date = row[INDEX_ZK_DATETIME]
       # so = row[INDEX_ZK_DdateATETIME]
        first_last_name = name.split(" ")
        user = User.where(firstname: first_last_name[0], lastname: first_last_name[1]).first
      
      # date =format_time(so)
          p name 
        p date.to_datetime
        p user
        unless name && date && user
          # missing name or date or no records found in database
          next
        end
        
        #        date = "#{date} #{Time.zone}".to_datetime
        date=date.to_datetime
        missed_checkouts = UserTimeCheck.
          where(['user_id = ? AND check_in_time < ? AND check_out_time IS NULL', 
            user.id, date.beginning_of_day])
        missed_checkouts.each do |missed_checkout|
          autogenerate_checkout(missed_checkout)
        end
        
        checkin_timechecks = UserTimeCheck.
          where(['user_id = ? AND check_in_time < ? AND check_in_time > ? AND check_out_time IS NULL', 
            user.id, date.end_of_day, date.beginning_of_day])
        p checkin_timechecks

        
        if checkin_timechecks.empty?
          checked_dates = UserTimeCheck.
            where(['user_id = ? AND check_in_time < ? AND check_in_time > ? AND check_out_time IS NOT NULL', 
              user.id, date.end_of_day, date.beginning_of_day])
          if checked_dates.empty?
            UserTimeCheck.create(user_id: user.id, check_in_time: date,check_out_time:  nil)
          end
          p '*'*50
          p user
          p '*'*50
        else
          user_time_check = checkin_timechecks.first
          checked_time = date.to_time - user_time_check.check_in_time.to_time
          difference = Time.at(checked_time).utc.strftime("%H").to_i
          if user_time_check.check_in_time.to_date == date.to_date
            if difference > 1 && difference < 16 
              #difference between first checkin and current pulled time is less than 16 and greater than 1 (meaning) not by mistake), so asssume checkout
              user_time_check.update_attributes(check_out_time: date,time_spent: checked_time/60)
              p '&'*50
            elsif difference > 16
              #difference between previous checkout and current is greater than 16, meaning that user missed out
              user_time_check.update_attributes(check_out_time: user_time_check.check_in_time + 6.hours, 
                comments: l(:auto_generated_comment),time_spent: 6*60)
              #   UserTimeCheck.create(user_id: user.id, check_in_time: date)
              p '$'*50

            else
              #ignore the check-in
            end
          elsif date.hour < 8 && difference > 1 && difference < 16
            #allow checkin/checkout for different days
            user_time_check.update_attributes(check_out_time: date,time_spent: checked_time/60)
          else
            #difference between previous checkout and current is greater than 16, meaning that user missed out
            autogenerate_checkout(user_time_check)
            UserTimeCheck.create(user_id: user.id, check_in_time: date)
            p '$'*50            
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
