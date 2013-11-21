class UserTimeChecksController < ApplicationController
  unloadable
  
  before_filter :require_login
  
  def check_in
    checkin_timechecks = UserTimeCheck.where(['user_id = ? AND check_out_time IS NULL', User.current.id])

    if checkin_timechecks.empty?
      @user_time_check = UserTimeCheck.create(user_id: User.current.id, check_in_time: DateTime.now)
    else
      flash.now[:error] = 'You did not check-out last time, please checkout first'
    end
  end
  
  def check_out
    checkout_timechecks = UserTimeCheck.where(['user_id = ? AND check_out_time IS NULL', User.current.id])
    
    if checkout_timechecks.empty?
      flash.now[:error] = 'You did not check-out last time, please checkout first'
    else
      @user_time_check = checkout_timechecks.first
      @user_time_check.update_attributes(check_out_time: DateTime.now)
      
      #if loggedintime<0.9*(user_time_check.check_out_time-@user_time_check.check_in_time)
         #flash.now[:error] = 'Your logged in  time is less than required Percentage. Log your remaining time'
         @issue= Issue.where(assigned_to_id: User.current.id)
         @time_entry= TimeEntry.where(user_id: User.current.id , spent_on: Date.today)
         #@issue= Issue.find(1)
     # end
    end
  end
  
  
  
end
