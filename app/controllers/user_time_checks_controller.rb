class UserTimeChecksController < ApplicationController
  unloadable
  
  before_filter :require_login
  
  def check_in
    checkin_timechecks = UserTimeCheck.where(['user_id = ? AND check_out_time IS NULL', User.current.id])

    if checkin_timechecks.empty?
      @user_time_check = UserTimeCheck.create(user_id: User.current.id, check_in_time: DateTime.now)
    else
      flash.now[:error] = 'You did not check-out last time, please check-out first'
      @user_time_check = checkin_timechecks.first
    end
  end
  
  def check_out
    checkout_timechecks = UserTimeCheck.where(['user_id = ? AND check_out_time IS NULL', User.current.id])
    
    if checkout_timechecks.empty?
      flash.now[:error] = 'You did not check-in last time, please check-in first'
      @user_time_check = UserTimeCheck.new(:user_id => User.current.id)

    else
      @user_time_check = checkout_timechecks.first
      @user_time_check.update_attributes(check_out_time: DateTime.now)
      
      @user_time_check.inspect
      
      @time_entry= TimeEntry.where(user_id: User.current.id , created_on: (@user_time_check.check_in_time)..@user_time_check.check_out_time)
  
      #@new_time_entry=TimeEntry.new
       #logged_in_time=@time_entry.sum(:hours)
      #if logged_in_time<(@user_time_check.check_out_time-@user_time_check.check_in_time)
         #flash.now[:error] = 'Your logged in  time is less than required Percentage. Log your remaining time'
         
         @assigned_issues= Issue.where(assigned_to_id: User.current.id)
         
         #@new_time_entries = Array.new(3) { assigned_issue.time_entries.build }
         @new_time_entries = []
         @assigned_issues.each do |assigned_issue|
          #@new_time_entries << TimeEntry.new(:issue_id => assigned_issue.id)
          @new_time_entries << assigned_issue.time_entries.build
         end
    #end
    end
  end
  
  
  
end
